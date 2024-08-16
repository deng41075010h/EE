#include <opencv2/highgui.hpp>
#include <opencv2/opencv.hpp>
#include <iostream>
#include <fstream>

using namespace cv;
using namespace std;

vector<vector<float>> errorStorage;
vector<float> r1, r2, r3, r4;

vector<vector<vector<Vec3f>>> readLUT(const string& filename);
vector<vector<int>> levels(int level_size);

void XYZ2LinearsRGB(float X, float Y, float Z, float* R, float* G, float* B);
void Lab2XYZ(float L, float a, float b, float* X, float* Y, float* Z);
void Lab2LinearsRGB_Vec3f(cv::Vec3f lab, cv::Vec3f* rgb);

void generate_labTxt();
void read_dimensions(ifstream& file, int& rows, int& cols);
void read_LabValue(ifstream& file , float& L, float& a, float& b);
Vec3f applyLUT(const Vec3f& lab, const vector<vector<vector<Vec3f>>>& lut);
void Floyd_Steinberg_algorithm(int row, int col, double error, int c, int rows, int cols);
Vec3f errorDiffusion(const Vec3f& pixel, int row, int col, const vector<vector<int>>& level, const int rows, const int cols);
Vec3b cfamapping(const Vec3f& pixel, int row, int col);

int main() {

	////////////////////////////////////////////
	// 產生 img_lab.txt
	////////////////////////////////////////////

	//generate_labTxt();

	////////////////////////////////////////////
	// 前置作業
	////////////////////////////////////////////
	
	// 讀檔 LUT
	vector<vector<vector<Vec3f>>> lut = readLUT("lab_to_rgb_lut.txt");
	// 建立3通道 16階level
	vector<vector<int>> level = levels(16);

	////////////////////////////////////////////
	// 讀檔 img_lab.txt
	////////////////////////////////////////////
	
	ifstream file("img_lab.txt");
	if(!file.is_open()){
		cout << "Failed to open file" << endl;
		return -1;
	}

	int rows, cols;
	read_dimensions(file, rows, cols);
	Mat img_lab(rows, cols, CV_32FC3, Scalar(0, 0, 0));
	Mat img_lab_enhance(rows, cols, CV_32FC3, Scalar(0, 0, 0));
	Mat img_LUT(rows, cols, CV_32FC3, Scalar(0, 0, 0));
	Mat img_errorDiffusion(rows, cols, CV_32FC3, Scalar(0, 0, 0));
	Mat img_CFA(rows, cols, CV_8UC3, Scalar(0, 0, 0));
	errorStorage = vector<vector<float>>(3, vector<float>(cols, 0.0f));
	r1 = vector<float>(3, 0.0f);
	r2 = vector<float>(3, 0.0f);
	r3 = vector<float>(3, 0.0f);
	r4 = vector<float>(3, 0.0f);


	for (int i = 0; i < rows; i++) {
		for (int j = 0; j < cols; j++) {
			float L, a, b;
			read_LabValue(file, L, a, b);
			// 存進對應的Mat位置，原始Tone.bmp
			img_lab.at<Vec3f>(i, j) = Vec3f(L, a, b);
			// color enhancement
			img_lab_enhance.at<Vec3f>(i, j) = Vec3f(L, a * 1.5, b * 1.5);

			// Lab to RGB with LUT
			//Vec3f labPixel = img_lab_enhance.at<Vec3f>(i, j);
			//Vec3f rgbPixel = applyLUT(labPixel, lut);
			//img_LUT.at<Vec3f>(i, j) = rgbPixel;
			
			// Lab to RGB with Math formula
			Vec3f labPixel = img_lab_enhance.at<Vec3f>(i, j);
			Vec3f rgbPixel;
			Lab2LinearsRGB_Vec3f(labPixel, &rgbPixel);
			img_LUT.at<Vec3f>(i, j) = rgbPixel;

			// Error Diffusion
			Vec3f pixel = img_LUT.at<Vec3f>(i, j);
			img_errorDiffusion.at<Vec3f>(i, j) = errorDiffusion(pixel, i, j, level, rows, cols);

			// CFAmapping
			Vec3f cfaPixel = img_errorDiffusion.at<Vec3f>(i, j);
			img_CFA.at<Vec3b>(i, j) = cfamapping(cfaPixel, i, j);

		}
	}
	file.close();

	// 將img_lab轉回BGR
	Mat img_bgr;
	cvtColor(img_lab, img_bgr, COLOR_Lab2BGR);

	// 將img_lab_enhance轉回BGR
	Mat img_bgr_enhance;
	cvtColor(img_lab_enhance, img_bgr_enhance, COLOR_Lab2BGR);

	// 將img_LUT轉換成8bit
	img_LUT.convertTo(img_LUT, CV_8UC3);

	// 將img_errorDiffusion轉換成8bit
	img_errorDiffusion.convertTo(img_errorDiffusion, CV_8UC3);

	// 將img_errorDiffusion結果輸出至.txt
	FileStorage fs("img_errorDiffusion.txt", FileStorage::WRITE);
	fs << "img_errorDiffusion" << img_errorDiffusion;
	fs.release();

	// 將img_CFA結果輸出至.txt
	FileStorage fs2("img_CFA.txt", FileStorage::WRITE);
	fs2 << "img_CFA" << img_CFA;
	fs2.release();

	// 將img_LUT儲存成img_LUT.bmp
	imwrite("img_LUT.bmp", img_LUT);

	// 將img_errorDiffusion儲存成img_errorDiffusion.bmp
	imwrite("img_errorDiffusion.bmp", img_errorDiffusion);

	// 將img_CFA儲存成img_CFA.bmp
	imwrite("img_CFA.bmp", img_CFA);


	//imshow("img", img_bgr);
	//imshow("img_enhance", img_bgr_enhance);
	//imshow("img_LUT", img_LUT);
	//imshow("img_errorDiffusion", img_errorDiffusion);
	//imshow("img_CFA", img_CFA);
	waitKey(0);




	return 0;
}

// CFA mapping，以符合CFA電子紙
Vec3b cfamapping(const Vec3f& pixel, int row, int col) {
	Vec3b newPixel;
	Vec3f rgbPixel(pixel[2], pixel[1], pixel[0]); // BGR換成RGB

	int a = floor(col / 3 + row);
	int b = a % 3; // 0 : B, 1 : G, 2 : R

	//int temp = ceil((int)pixel[b]); // B, G, R
	int temp = ceil((int)rgbPixel[b]); // R, G, B

	newPixel[0] = temp;
	newPixel[1] = temp;
	newPixel[2] = temp;

	return newPixel;
}

// 誤差擴散演算法，加回儲存的誤差值errorStorage、r1，計算當前pixel的誤差擴散值，並量化成level值
Vec3f errorDiffusion(const Vec3f& pixel, int row, int col, const vector<vector<int>>& level, const int rows, const int cols) {
	Vec3f newPixel;

	for (int c = 0; c < 3; c++) {

		newPixel[c] = pixel[c] + errorStorage[c][col] + r1[c];
		if(newPixel[c] < 0) newPixel[c] = 0;
		if(newPixel[c] > 240) newPixel[c] = 240;

		for(int l = 0; l < level[c].size(); l++) {

			if (newPixel[c] > level[c][l] && newPixel[c] < level[c][l + 1]) {
				
				if(abs(newPixel[c] - level[c][l]) < abs(newPixel[c] - level[c][l + 1])) {
					double error = newPixel[c] - level[c][l];
					Floyd_Steinberg_algorithm(row, col, error, c, rows, cols);
					newPixel[c] = level[c][l];
				}
				else {
					double error = newPixel[c] - level[c][l + 1];
					Floyd_Steinberg_algorithm(row, col, error, c, rows, cols);
					newPixel[c] = level[c][l + 1];
				}
				break;
			}
			else if (newPixel[c] == level[c][l]) { // 當newPixel==level時，以0為error送進FS algorithm，將暫存器歸零
				double error = newPixel[c] - level[c][l];
				Floyd_Steinberg_algorithm(row, col, error, c, rows, cols);
				break;
			}
		}
	}
	return newPixel;
}

// 計算誤差，並存進暫存器 (r1, r2, r3, r4) 以及 memory (errorStorage)
void Floyd_Steinberg_algorithm(int row, int col, double error, int c, int rows, int cols) {
	
	double w1 = 7.0 / 16.0;
	double w2 = 1.0 / 16.0;
	double w3 = 5.0 / 16.0;
	double w4 = 3.0 / 16.0;


	if (col - 1 >= 0 && row + 1 < rows) {
		r4[c] = r3[c] + error * w4;
		errorStorage[c][col - 1] = r4[c];
	}
	if (row + 1 < rows) {
		r3[c] = r2[c] + error * w3;
		errorStorage[c][col] = r3[c];
	}
	if (col + 1 < cols && row + 1 < rows)
		r2[c] = error * w2;
	else
		r2[c] = 0; // 當最後一排col時，r2 = 0
	if (col + 1 < cols) 
		r1[c] = error * w1;
	else 
		r1[c] = 0; // 當最後一排col時，r1 = 0
	
	
}

// 使用 LUT 查表，將Lab轉換成BGR
Vec3f applyLUT(const Vec3f& lab, const vector<vector<vector<Vec3f>>>& lut) {
	int l = min(31, max(0, static_cast<int>(lab[0] * 31.0 / 100.0))); // 0~100 -> 0~31
	int a = min(31, max(0, static_cast<int>((lab[1] + 128.0) * 31.0 / 255.0))); // -128~127 -> 0~255 -> 0~31
	int b = min(31, max(0, static_cast<int>((lab[2] + 128.0) * 31.0 / 255.0))); // -128~127 -> 0~255 -> 0~31

	return lut[l][a][b];
}

// 讀取L, a, b
void read_LabValue(ifstream& file, float& L, float& a, float& b) {
	string line;
	getline(file, line);
	stringstream ss(line);
	char comma;
	ss >> L >> comma >> a >> comma >> b >> comma;
	//cout << L << " " << a << " " << b << endl;
}

// 讀取rows, cols
void read_dimensions(ifstream& file, int& rows, int& cols) {
	string line;
	getline(file, line);
	stringstream ss(line);
	string c;
	ss >> c >> rows;
	getline(file, line);
	stringstream ss2(line);
	ss2 >> c >> cols;
	cout << rows << " x " << cols << endl;
	getline(file, line);
}

// 產生img_lab.txt
void generate_labTxt() {

	Mat img = imread("Tone.bmp");
	img.convertTo(img, CV_32FC3, 1.0 / 255);
	Mat img_lab;
	cvtColor(img, img_lab, COLOR_BGR2Lab);

	// 寫檔 img_lab.txt
	ofstream file("img_lab.txt");
	if (file.is_open()) {
		file << "rows: " << img_lab.rows << endl;
		file << "cols: " << img_lab.cols << endl;
		file << "data: " << endl;
		for (int i = 0; i < img_lab.rows; i++) {
			for (int j = 0; j < img_lab.cols; j++) {
				Vec3f lab = img_lab.at<Vec3f>(i, j);
				file << lab[0] << ", " << lab[1] << ", " << lab[2] << ", " << endl;
			}
			//file << endl;
		}
	}
	file.close();
}

// 讀取查找表函數
vector<vector<vector<Vec3f>>> readLUT(const string& filename) {
	ifstream file(filename);
	vector<vector<vector<Vec3f>>> lut(32, vector<vector<Vec3f>>(32, vector<Vec3f>(32)));
	if (file.is_open()) {
		string line;
		getline(file, line);

		for (int l = 0; l < 32; l++) {
			for (int a = 0; a < 32; a++) {
				for (int b = 0; b < 32; b++) {
					getline(file, line);
					stringstream ss(line);
					float L, A, B, R, G, B_val;
					char comma, dash1, dash2;
					ss >> L >> comma >> A >> comma >> B >> comma >> dash1 >> dash2 >> comma >> R >> comma >> G >> comma >> B_val;
					//lut[l][a][b] = Vec3f(R, G, B_val);
					lut[l][a][b] = Vec3f(B_val, G, R); // 換成BGR
				}
			}
		}
		file.close();
	}
	else {
		cerr << "Unable to open file" << endl;
	}


	return lut;
}

// 建立3通道16階level
vector<vector<int>> levels(int level_size) {
	vector<vector<int>> level(3, vector<int>(level_size));
	for (int i = 0; i < 3; i++) {
		vector<int> temp;
		for(int j = 0; j < level_size; j++) {
			temp.push_back(j * (256 / level_size));
		}
		level[i] = temp;
	}
	return level;
}

// Lab to BGR with Math formula
void Lab2LinearsRGB_Vec3f(cv::Vec3f lab, cv::Vec3f* rgb) {
	float X, Y, Z, R, G, B;
	Lab2XYZ(lab[0], lab[1], lab[2], &X, &Y, &Z);
	XYZ2LinearsRGB(X, Y, Z, &R, &G, &B);
	//B = (B >= 1) ? 255 : B * 255.0;
	//G = (G >= 1) ? 255 : G * 255.0;
	//R = (R >= 1) ? 255 : R * 255.0;
	if (B < 0) B = 0;
	if (G < 0) G = 0;
	if (R < 0) R = 0;
	if (B > 1) B = 1;
	if (G > 1) G = 1;
	if (R > 1) R = 1;
	B = B * 255.0;
	G = G * 255.0;
	R = R * 255.0;

	*rgb = cv::Vec3f(B, G, R);
}

// XYZ to Linear sRGB (不做 gamma 會比較暗)
void XYZ2LinearsRGB(float X, float Y, float Z, float* R, float* G, float* B)
{
	float RR, GG, BB;
	RR = 3.2404542f * X - 1.5371385f * Y - 0.4985314f * Z;
	GG = -0.9692660f * X + 1.8760108f * Y + 0.0415560f * Z;
	BB = 0.0556434f * X - 0.2040259f * Y + 1.0572252f * Z;

	//RR = 3.1338561f * X - 1.6168667f * Y - 0.4906146f * Z;
	//GG = -0.9787684f * X + 1.9161415f * Y + 0.0334540f * Z;
	//BB = 0.0719453f * X - 0.2289914f * Y + 1.4052427f * Z;
	//RR = gamma_XYZ2RGB(RR);
	//GG = gamma_XYZ2RGB(GG);
	//BB = gamma_XYZ2RGB(BB);

	// Apply gamma correction
	//RR = (RR > 0.0031308) ? (1.055 * pow(RR, 1.0 / 2.4) - 0.055) : (12.92 * RR);
	//GG = (GG > 0.0031308) ? (1.055 * pow(GG, 1.0 / 2.4) - 0.055) : (12.92 * GG);
	//BB = (BB > 0.0031308) ? (1.055 * pow(BB, 1.0 / 2.4) - 0.055) : (12.92 * BB);

	//RR = clip255(RR * 255.0 + 0.5);
	//GG = clip255(GG * 255.0 + 0.5);
	//BB = clip255(BB * 255.0 + 0.5);

	*R = RR;
	*G = GG;
	*B = BB;
}

// Lab to XYZ
void Lab2XYZ(float L, float a, float b, float* X, float* Y, float* Z)
{
	const float param_16116 = 16.0f / 116.0f;
	//#ifdef D65
	const float Xn = 0.950456f;
	const float Yn = 1.0f;
	const float Zn = 1.088754f;
	//#else
		//const float Xn = 0.964212f;
		//const float Yn = 1.0f;
		//const float Zn = 0.825188f;
	//#endif // D65
	float fX, fY, fZ;
	fY = (L + 16.0f) / 116.0;
	fX = a / 500.0f + fY;
	fZ = fY - b / 200.0f;

	if (powf(fY, 3.0) > 0.008856)
		*Y = fY * fY * fY;
	else
		*Y = (fY - param_16116) / 7.787f;

	if (powf(fX, 3.0) > 0.008856)
		*X = fX * fX * fX;
	else
		*X = (fX - param_16116) / 7.787f;

	if (powf(fZ, 3.0) > 0.008856)
		*Z = fZ * fZ * fZ;
	else
		*Z = (fZ - param_16116) / 7.787f;

	(*X) *= (Xn);
	(*Y) *= (Yn);
	(*Z) *= (Zn);
}