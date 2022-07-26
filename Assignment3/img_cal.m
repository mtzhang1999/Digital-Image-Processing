function img_cal(img_dir, mask_dir, bg_dir, img_format)
    img = imread(img_dir);
    bg = imread(bg_dir);
    if img_format == "jpg"
        mask = uint8(imread(mask_dir));
    else
        if img_format == "mat"
            load(mask_dir, '-mat');
            mask = uint8(mask) * 255;
        end
    end
    img_masked = bitand(img, mask);
    figure
    imshow(img_masked)
    bg_masked = bitand(bg, bitcmp(mask));
    img_cmb = img_masked + bg_masked;
    figure
    imshow(img_cmb)
    if img_format == "MAT"
        clear mask
    end
end