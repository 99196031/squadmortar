import cv2
import time
import sys


def overlay_images(image_path1, image_path2, output_path):
    # read images
    img1 = cv2.imread(image_path1)
    img2 = cv2.imread(image_path2)

    # resize images
    img1 = cv2.resize(img1, (img2.shape[1], img2.shape[0]), interpolation=cv2.INTER_LINEAR)
    
    # blend images
    img_out = cv2.addWeighted(img1, 0.7, img2, 0.45, 0)

    # save the output
    cv2.imwrite(output_path, img_out)

# start timer
#start_time = time.time()

# call the function
image_path1, image_path2, output_path = sys.argv[1], sys.argv[2], sys.argv[3]
overlay_images(image_path1, image_path2, output_path)

# print execution time
#print("--- %s seconds ---" % (time.time() - start_time))