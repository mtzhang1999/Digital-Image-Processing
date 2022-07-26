import cv2
import numpy as np

def RGB(img, R, G, B, save_name):
    cv2.imwrite(save_name + "_R.jpg", R)
    cv2.imwrite(save_name + "_G.jpg", G)
    cv2.imwrite(save_name + "_B.jpg", B)

def CMY(img, R, G, B, save_name):
    C = 255 - R
    M = 255 - G
    Y = 255 - B
    cv2.imwrite(save_name + "_C.jpg", C)
    cv2.imwrite(save_name + "_M.jpg", M)
    cv2.imwrite(save_name + "_Y.jpg", Y)

def HSI(img, R, G, B, save_name):
    # calculate H
    H = np.true_divide((R * 2 - G - B) / 2, np.sqrt((R - G) ** 2 + (R - B) * (G - B)))
    H[~np.isfinite(H)] = 1
    H = np.arccos(H)
    H[G < B] = 2 * np.pi - H[G < B]
    H = H / (2 * np.pi) * 255

    # calculate S
    S = 1 - 3 * np.true_divide(img.min(2), img.sum(2))
    S[~np.isfinite(S)] = 0
    S = S * 255

    # calculate I
    I = img.mean(2)

    cv2.imwrite(save_name + "_H.jpg", H)
    cv2.imwrite(save_name + "_S.jpg", S)
    cv2.imwrite(save_name + "_I.jpg", I)

def work(img_name, save_name):
    img = cv2.imread(img_name)
    img = np.array(img)
    B = np.array(img[:, :, 0], dtype = float)
    G = np.array(img[:, :, 1], dtype = float)
    R = np.array(img[:, :, 2], dtype = float)
    RGB(img, R, G, B, save_name)
    CMY(img, R, G, B, save_name)
    HSI(img, R, G, B, save_name)

if __name__ == '__main__':
    work('pic2.jpg', 'pic2')