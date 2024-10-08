/**
 
 VisualDub Project
 Open A Window of 640x320
 Load an Image which jpg or png .... convert it to qoi format (https://github.com/phoboslab/qoi)
 Run a face detector
 show the face bounding box on the image
 
 */

#include <iostream>
#include <opencv2/opencv.hpp>
#include <Foundation/Foundation.h>
#include <fstream>
#include <vector>
#include "qoi.h"

class ImageQOIProcessor {
public:
	ImageQOIProcessor(const std::string& windowName, int width, int height)
		: mWindowName(windowName), mWidth(width), mHeight(height) {}

	cv::Mat loadImage(const std::string& imagePath);
	bool saveQOI(const cv::Mat& img, const std::string& outputPath);
	void displayImage(const cv::Mat& img);
	void detectAndDisplayFaces(cv::Mat& img);
	cv::Mat loadQOI(const std::string& inputPath);

private:
	std::string mWindowName = "";
	int mWidth = 0;
	int mHeight = 0;
};

cv::Mat ImageQOIProcessor::loadImage(const std::string& imagePath) {
	cv::Mat image = cv::imread(imagePath);
	if (image.empty()) {
		std::cerr << "Error: Could not load image from " << imagePath << std::endl;
		throw std::runtime_error("Image loading failed");
	}
	return image;
}

bool ImageQOIProcessor::saveQOI(const cv::Mat& img, const std::string& outputPath) {
	cv::Mat img_rgba;
	if (img.channels() == 3) {
		cv::cvtColor(img, img_rgba, cv::COLOR_BGR2BGRA);
	} else {
		img_rgba = img; // Already in RGBA format
	}

	int qoi_size;
	qoi_desc desc = {
			static_cast<unsigned int>(img_rgba.cols),
			static_cast<unsigned int>(img_rgba.rows),
			4,   // Number of channels (RGBA)
			0 	// colorSpace
		};
	uint8_t* qoi_data = (uint8_t*)qoi_encode(img_rgba.data, &desc, &qoi_size);
	
	if (!qoi_data) {
		std::cerr << "Error: Encoding failed!" << std::endl;
		return false;
	}

	std::ofstream out_file(outputPath, std::ios::binary);
	if (out_file) {
		out_file.write(reinterpret_cast<const char*>(qoi_data), qoi_size);
		out_file.close();
		std::cout << "QOI image saved as " << outputPath << std::endl;
	} else {
		std::cerr << "Error: Could not save QOI file!" << std::endl;
		free(qoi_data);
		return false;
	}
	free(qoi_data);
	return true;
}

cv::Mat ImageQOIProcessor::loadQOI(const std::string& inputPath) {
	std::ifstream inputFile(inputPath, std::ios::binary);
	if (!inputFile.is_open()) {
		std::cerr << "Error: Could not open QOI file." << std::endl;
		throw std::runtime_error("QOI loading failed");
	}

	// Read QOI file into a vector
	inputFile.seekg(0, std::ios::end);
	size_t fileSize = inputFile.tellg();
	inputFile.seekg(0, std::ios::beg);

	std::vector<unsigned char> qoiData(fileSize);
	inputFile.read(reinterpret_cast<char*>(qoiData.data()), fileSize);
	inputFile.close();

	// Decode QOI data
	qoi_desc desc;
	void* pixels = qoi_decode(qoiData.data(), fileSize, &desc, 4); // RGBA

	if (!pixels) {
		std::cerr << "Error: Decoding QOI failed!" << std::endl;
		throw std::runtime_error("QOI decoding failed");
	}
	
	// Create an OpenCV Mat object from the decoded data
		cv::Mat img(desc.height, desc.width, CV_8UC4, pixels);  // 4 channels (RGBA)
		cv::Mat imgBGR;
		cv::cvtColor(img, imgBGR, cv::COLOR_RGBA2BGR);  // Convert RGBA to BGR for OpenCV

		// Free the decoded QOI data
		free(pixels);
		return imgBGR;
	}


void ImageQOIProcessor::displayImage(const cv::Mat& img) {
	cv::namedWindow(mWindowName, cv::WINDOW_NORMAL);
	cv::resizeWindow(mWindowName, mWidth, mHeight);
	cv::imshow(mWindowName, img);
	cv::waitKey(0);
	cv::destroyWindow(mWindowName);
}

void ImageQOIProcessor::detectAndDisplayFaces(cv::Mat& img) {
	cv::Mat gray;
	cv::cvtColor(img, gray, cv::COLOR_BGR2GRAY);
	
	cv::CascadeClassifier faceCascade;
	if (!faceCascade.load("Resources/haarcascade_frontalface_default.xml")) {
		std::cerr << "Error: Could not load Haar cascade!" << std::endl;
		throw std::runtime_error("Face cascade loading failed");
	}
	
	std::vector<cv::Rect> faces;
	faceCascade.detectMultiScale(gray, faces, 1.1, 3, 0, cv::Size(30, 30));

	for (const auto& face : faces) {
		cv::rectangle(img, face, cv::Scalar(255, 0, 0), 2);
	}
	displayImage(img);
}

int main(int argc, const char* argv[]) {
	const int width = 640;
	const int height = 320;
	const std::string windowName = "My Window";
	
	NSBundle* bundle = [NSBundle mainBundle];
	NSString* resourcePath = [bundle resourcePath];
	NSString* imagePath = [resourcePath stringByAppendingPathComponent:@"Resources/SampleImage3.jpeg"];
	std::string imagePathC = [imagePath UTF8String];

	try {
		ImageQOIProcessor processor(windowName, width, height);
		cv::Mat image = processor.loadImage(imagePathC);
		if (processor.saveQOI(image, "output.qoi")) {
			
			cv::Mat qoiImage = processor.loadQOI("output.qoi");
			processor.detectAndDisplayFaces(qoiImage);
		}
	} catch (const std::runtime_error& e) {
		std::cerr << e.what() << std::endl;
		return -1;
	}
	
	std::filesystem::path currentPath = std::filesystem::current_path();
	std::cout << "Current working directory: " << currentPath << std::endl;

	return 0;
}
