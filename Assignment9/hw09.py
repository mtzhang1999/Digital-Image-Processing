import numpy as np
import cv2
from matplotlib import pyplot as plt

Mode = ["GLOBAL", "ADAPTIVE", "OTSU", "MORPHO"]

def iterate_threshold(img, thre = 126, thre0 = 0):
    thre_last = 0
    while abs(int(thre_last) - int(thre)) > thre0:
        thre_last = thre
        img_hist = cv2.calcHist([img], [0], None, [256], [0, 256]).reshape(-1)
        img_1 = 0
        img_2 = 0
        for i in range(256):
            if i < thre:
                img_1 = img_1 + i * img_hist[i]
            else:
                img_2 = img_2 + i * img_hist[i]
        img_1 = img_1 / np.sum(img_hist[0 : thre])
        img_2 = img_2 / np.sum(img_hist[thre : ])
        thre = np.uint8((img_1 + img_2) / 2)
    return thre


if __name__ == "__main__":
    Pro_Mode = Mode[3]
    img = cv2.imread("trove.png", 0)
    IMG_THRESH = iterate_threshold(img)
    MAX_THRESH = 255
    if Pro_Mode == Mode[0]:
        _, image_1 = cv2.threshold(img, IMG_THRESH, MAX_THRESH, cv2.THRESH_BINARY)
        _, image_2 = cv2.threshold(img, IMG_THRESH, MAX_THRESH, cv2.THRESH_BINARY_INV)
        _, image_3 = cv2.threshold(img, IMG_THRESH, MAX_THRESH, cv2.THRESH_TRUNC)
        _, image_4 = cv2.threshold(img, IMG_THRESH, MAX_THRESH, cv2.THRESH_TOZERO)
        _, image_5 = cv2.threshold(img, IMG_THRESH, MAX_THRESH, cv2.THRESH_TOZERO_INV)
        
        titles = ["Original", "BINARY", "BINARY_INV", "THRESH_TRUNC", "THRESH_TOZERO", "THRESH_TOZERO_INV"]
        imgs = [img, image_1, image_2, image_3, image_4, image_5]

        for i in range(6):
            plt.subplot(2, 3, i + 1)
            plt.imshow(imgs[i], 'gray')
            plt.title(titles[i])
            plt.xticks([]), plt.yticks([])
    
    if Pro_Mode == Mode[1]:
        BLOCK_SIZE = 15
        C = 2
        image_1 = cv2.adaptiveThreshold(img, MAX_THRESH, cv2.ADAPTIVE_THRESH_MEAN_C, \
                                    cv2.THRESH_BINARY, BLOCK_SIZE, C)
        image_2 = cv2.adaptiveThreshold(img, MAX_THRESH, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, \
                                    cv2.THRESH_BINARY, BLOCK_SIZE, C)
        
        titles = ["Original", "Adaptive Mean", "Adaptive Gaussian"]
        imgs = [img, image_1, image_2]

        for i in range(3):
            plt.subplot(1, 3, i+1)
            plt.imshow(imgs[i], 'gray')
            plt.title(titles[i])
            plt.xticks([]), plt.yticks([])
    

    if Pro_Mode == Mode[2]:
        _, image_1 = cv2.threshold(img, 0, MAX_THRESH, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        
        titles = ["Original", "Otsu"]
        imgs = [img, image_1]

        for i in range(2):
            plt.subplot(1, 2, i+1)
            plt.imshow(imgs[i], 'gray')
            plt.title(titles[i])
            plt.xticks([]), plt.yticks([])

    if Pro_Mode == Mode[3]:
        ker = np.ones((3, 3), dtype = np.uint8)

        image_1 = cv2.dilate(img, ker, iterations=1)
        image_2 = cv2.adaptiveThreshold(image_1, MAX_THRESH, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 31, 3)
        image_3 = cv2.erode(image_2, ker, iterations=1)

        titles = ["Original", "1", "2", "3"]
        imgs = [img, image_1, image_2, image_3]

        for i in range(4):
            plt.subplot(2, 2, i + 1)
            plt.imshow(imgs[i], 'gray')
            plt.title(titles[i])
            plt.xticks([]), plt.yticks([])

    plt.show()