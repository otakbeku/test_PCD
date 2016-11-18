%Ngambil videonya
videoIn = VideoReader('testvideoavi');%bisa diganti sama traffic
%ngubah jadi gelap
videoIn_Gelap= rgb2gray(read(videoIn,71));

value_Gelap = 50;
%proses threshold. Syntaxnya buat ngilangin yang dibawah nilai gelap
videoIn_tanpaGelap = imextendedmax(videoIn_Gelap,value_Gelap);

%ngetest frame pertama berhasil di threshold atau ga
%imshow(videoIn_Gelap);
%figure, imshow(videoIn_tanpaGelap);

%buat ngeplay videonya
%get(videoIn);
%implay('testvideo1.avi');

%Strel = STructuring ELement. Untuk morphological structuring element
set = strel('disk',2);

%imopen =>buat marking (sepertinya)
videoHapus_Struktur = imopen(videoIn_tanpaGelap, set);

subplot(131); imshow(videoIn_Gelap);
subplot(132); imshow(videoIn_tanpaGelap);
subplot(133); imshow(videoHapus_Struktur);

%PROSES MEMBACA TIAP FRAME
jumlahFrame = get(videoIn, 'NumberOfFrames');
ImagePerFrame = read(videoIn, 1);

%Nentuin ukuran marking
tagged = zeros([size(ImagePerFrame,1) size(ImagePerFrame,2) 3 jumlahFrame], class(ImagePerFrame));
for frame = 1 : jumlahFrame
    singleFrame = read(videoIn, frame);
    
    %diubah ke grayscale
    ImagePerFrame = rgb2gray(singleFrame);
    
    %ngehapus bagian gelap
    ImageNoGelap = imextendedmax(ImagePerFrame,value_Gelap);
    
    %ngehapus bentuk
    noStructures = imopen(ImageNoGelap, set);
    
    %ngehapus struktur (?)
    noStructures = bwareaopen(noStructures,150);
    
    %Buat marking
    %masih error disini: Assignment has fewer non-singleton rhs dimensions than non-singleton subscripts
    tagged(:,:,:,frame) = singleFrame;
    
    stats = regionprops(noStructures,{'Centroid','Area'});
    if ~isempty([stats.Area])
        areaArray = [stats.Area];
        [junk,idx] = max(areaArray);
        c = stats(idx).Centroid;
        c = floor(fliplr(c));
        width = 2;
        row = c(1)-width:c(1)+width;
        col = c(2)-width:c(2)+width;
        tagged(row,col,1,frame) = 255;%markingnya warna merah
        tagged(row,col,2,frame) = 0;
        tagged(row,col,3,frame) = 0;
    end
end

%frame rate dan play
frameRate = get(videoIn, 'FrameRate');
implay(tagged, frameRate);

    
    
