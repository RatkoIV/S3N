clc
clear all
% Učitavanje originalne slike
original_image = imread('C:\Users\Bato\Desktop\RADOVI 2024\SNOW & RAIN\Test.png');
original_image = im2double(original_image); % Konverzija u double radi preciznosti

% Dimenzije slike
[M, N, C] = size(original_image);

% Parametri snega
intensity_param = 300; % Intenzitet snega (0–1000, npr. 500 = 50% pokrivenosti)
coverage = intensity_param / 1000; % Procenat piksela slike pokrivenih pahuljicama
num_snow_pixels = round(M * N * coverage); % Ukupan broj piksela sa snegom
orientation = -30; % Orijentacija pahuljica u stepenima (npr. -30 za dijagonalno levo)
min_size = 1; % Minimalna veličina pahuljica (u pikselima)
max_size = 5; % Maksimalna veličina pahuljica (u pikselima)
min_intensity = 0.5; % Minimalna osvetljenost pahuljica (sive pahuljice)
max_intensity = 1.0; % Maksimalna osvetljenost pahuljica (bele pahuljice)

% Kreiranje sloja za sneg
snow_layer = zeros(M, N); % Sloj za intenzitete snega
covered_pixels = 0; % Brojač pokrivenih piksela

% Generisanje snežnih pahuljica sa različitim karakteristikama
while covered_pixels < num_snow_pixels
    % Slučajne koordinate centra pahulje
    x_center = randi([1, M]);
    y_center = randi([1, N]);
    
    % Nasumična veličina i intenzitet pahulje
    size_flake = randi([min_size, max_size]); % Veličina pahulje u pikselima
    z_depth = rand(); % Dubina (bliže ili dalje)
    intensity = min_intensity + (max_intensity - min_intensity) * (1 - z_depth); % Svetlost
    
    % Kreiranje pahulje sa blur efektom
    blur_amount = randi([1, 3]); % Nasumičan nivo zamućenja (1 = oštro, 3 = zamućeno)
    [x, y] = meshgrid(-size_flake:size_flake, -size_flake:size_flake);
    distance = sqrt(x.^2 + y.^2);
    flake_mask = exp(-(distance / blur_amount).^2); % Gaussova funkcija za zamućenje
    flake_mask(distance > size_flake) = 0; % Ograničenje veličine pahulje
    
    % Transformacija orijentacije pahulje
    x_rot = round(x_center + x * cosd(orientation) - y * sind(orientation));
    y_rot = round(y_center + x * sind(orientation) + y * cosd(orientation));
    
    % Dodavanje pahulje na sloj snega
    for i = 1:numel(flake_mask)
        x_flake = x_rot(i);
        y_flake = y_rot(i);
        
        % Proveravamo da li su koordinate unutar granica slike
        if x_flake > 0 && x_flake <= M && y_flake > 0 && y_flake <= N
            if snow_layer(x_flake, y_flake) == 0 % Sprečavamo dvostruko prekrivanje
                snow_layer(x_flake, y_flake) = intensity * flake_mask(i);
                covered_pixels = covered_pixels + 1;
            end
            
            % Ako dostignemo tačan broj snežnih piksela, prekidamo petlju
            if covered_pixels >= num_snow_pixels
                break;
            end
        end
    end
end

% Dodavanje sloja snega na originalnu sliku
snow_image = original_image + repmat(snow_layer, [1, 1, C]); % Ponavljamo sloj za svaki kanal
snow_image = min(snow_image, 1); % Osiguravamo da pikseli ne prelaze 1 (maksimalna osvetljenost)

% Prikaz rezultata
figure (10);
imshow(original_image); title('Originalna slika');
figure (20);
imshow(snow_image); title('Slika sa efektom snega');
imwrite(snow_image,'C:\Users\Bato\Desktop\RADOVI 2024\SNOW & RAIN\Test+snow.png')

% Čuvanje slike
imwrite(snow_image, 'snow_image_with_blur.png');

% Prikaz histograma razlike
difference = abs(original_image - snow_image); % Razlika između originalne i snežne slike
figure (30);
imhist(difference(:)); title('Histogram of Intensity Differencee');
xlim([-5 260]); % Set x-axis range to [-5, 260]
xlabel('Pixel Intensity'); ylabel('Number of Pixels');
















% Prikaz slike sa efektom snega na uniformnoj slici (Figure 4)
% Generisanje uniformne sive slike kao osnove za analizu
uniform_image = uint8(128 * ones(M, N)); % Grayscale vrednost na sredini 8-bitnog spektra
uniform_image_double = im2double(uniform_image); % Konverzija u double preciznost

% Dodavanje snega na uniformnu sliku
snow_layer_uniform = zeros(M, N); % Sloj za intenzitete snega za uniformnu sliku
covered_pixels_uniform = 0; % Brojač pokrivenih piksela za uniformnu sliku

% Ponovno generisanje snega za uniformnu sliku
while covered_pixels_uniform < num_snow_pixels
    x_center = randi([1, M]);
    y_center = randi([1, N]);
    
    size_flake = randi([min_size, max_size]);
    z_depth = rand();
    intensity = min_intensity + (max_intensity - min_intensity) * (1 - z_depth);
    
    blur_amount = randi([1, 3]);
    [x, y] = meshgrid(-size_flake:size_flake, -size_flake:size_flake);
    distance = sqrt(x.^2 + y.^2);
    flake_mask = exp(-(distance / blur_amount).^2);
    flake_mask(distance > size_flake) = 0;
    
    x_rot = round(x_center + x * cosd(orientation) - y * sind(orientation));
    y_rot = round(y_center + x * sind(orientation) + y * cosd(orientation));
    
    for i = 1:numel(flake_mask)
        x_flake = x_rot(i);
        y_flake = y_rot(i);
        if x_flake > 0 && x_flake <= M && y_flake > 0 && y_flake <= N
            if snow_layer_uniform(x_flake, y_flake) == 0
                snow_layer_uniform(x_flake, y_flake) = intensity * flake_mask(i);
                covered_pixels_uniform = covered_pixels_uniform + 1;
            end
            if covered_pixels_uniform >= num_snow_pixels
                break;
            end
        end
    end
end

% Generisanje slike sa snežnim efektom za uniformnu sliku
snow_image_uniform = uniform_image_double + snow_layer_uniform;
snow_image_uniform = min(snow_image_uniform, 1); % Ograničenje na maksimalnu vrednost 1

% Prikaz Figure 4
figure (40);
imshow(snow_image_uniform); title('Snow Noise Applied to Uniform Image (Figure 4)');

% Generisanje histograma originalne i snežne slike (Figure 5)
figure (50);
imhist(uniform_image_double(:)); title('Histogram of Uniform Image (Figure 5a)');
xlim([-5 260]); % Set x-axis range to [-5, 260]
xlabel('Pixel Intensity'); ylabel('Number of Pixels');

figure (55);
imhist(snow_image_uniform(:)); title('Histogram of Snowy Image (Figure 5b)');
xlim([-5 260]); % Set x-axis range to [-5, 260]
xlabel('Pixel Intensity'); ylabel('Number of Pixels');

% Generisanje histograma razlike za uniformnu sliku (Figure 6)
difference_uniform = abs(uniform_image_double - snow_image_uniform); % Razlika intenziteta
figure (60);
imhist(difference_uniform(:)); title('Histogram of Intensity Difference (Figure 6)');
xlim([-5 260]); % Set x-axis range to [-5, 260]
xlabel('Intensity Difference'); ylabel('Number of Pixels');






% Prikaz Figure 5a - Histogram uniformne slike
figure(500);
imhist(uniform_image_double(:)); % Histogram uniformne slike
title('Histogram of Uniform Image (Figure 5a)');
xlim([-5 260]); % Ograničenje x-ose
xlabel('Pixel Intensity'); ylabel('Number of Pixels');

% Prikaz Figure 5b - Histogram snežne slike
figure(550);
imhist(snow_image_uniform(:)); % Histogram snežne slike
title('Histogram of Snowy Image (Figure 5b)');
xlim([-5 260]); % Ograničenje x-ose
xlabel('Pixel Intensity'); ylabel('Number of Pixels');





% Generisanje uniformne slike
uniform_image1 = uint8(128 * ones(M, N)); % Uniformna slika sa vrednostima 128
uniform_image_double = im2double(uniform_image1); % Konverzija u double radi preciznosti

% Prikaz histograma uniformne slike
figure(1500); % Postavljanje broja figure
imhist(uint8(uniform_image1)); % Histogram uniformne slike u uint8 formatu
title('Histogram of the Uniform Image');
xlabel('Pixel Intensity');
ylabel('Number of Pixels');
xlim([-5 260]); % Prikaz samo opsega oko vrednosti 128

% Dodavanje snežnog šuma slici uniform_image1
snowy_uniform_image = uniform_image_double + snow_layer_uniform; % Dodavanje snežnog sloja
snowy_uniform_image = min(snowy_uniform_image, 1); % Ograničenje na opseg [0, 1]

% Prikaz histograma slike sa dodatim snežnim šumom
figure(2500); % Postavljanje broja figure
imhist(uint8(snowy_uniform_image * 255)); % Histogram slike sa snežnim šumom skalirane na 8-bitni opseg
title('Histogram of Uniform Image with Added Snow Noise');
xlabel('Pixel Intensity');
ylabel('Number of Pixels');
xlim([-5 260]); % Prikaz opsega od -5 do 260