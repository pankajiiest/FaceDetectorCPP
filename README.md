**Overview **
This project demonstrates the usage of the QOI (Quite OK Image) format for image encoding/decoding, along with running OpenCV face detection on a QOI image. It allows the following:

Load a JPEG/PNG image. 
Convert the image to QOI format and save it. 
Decode the QOI image back to an OpenCV cv::Mat. 
Run a face detector on the decoded QOI image and draw bounding boxes around the detected faces.
Display the final image with bounding boxes around detected faces.

To handle resources during load from project, objective C++ has been used.

**Key Libraries Used:**
OpenCV : For image processing, face detection, and displaying images.
QOI (Quite OK Image): A fast lossless image format used for encoding and decoding images. Apple Foundation Framework (for macOS users): Provides utilities to interact with macOS bundles for resource handling. (Like NSBundle etc)

**Required Libraries:** OpenCV: To install OpenCV, use the following: brew install opencv

To see the install location : brew --prefix opencv

QOI Library: The project uses the QOI image format for encoding and decoding. The qoi.h header file is included in the project.

GitHub repo: QOI - https://github.com/phoboslab/qoi?tab=readme-ov-file

**Setup and Compilation for Xcode**

Clone the Repository : git clone https://github.com/your-username/qoi-face-detection.git
open MyFaceDetectorCPP.xcodeproj
Install OpenCV (via Homebrew)
Build and Run the Project using Cmd + R . Xcode will compile the code and run the face detection program. You should see the output window showing the loaded image with bounding boxes around detected faces.
