KSPhotoBrowser
==============
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/skx926/KSPhotoBrowser/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/KSPhotoBrowser.svg?style=flat)](http://cocoapods.org/?q=KSPhotoBrowser)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/KSPhotoBrowser.svg?style=flat)](http://cocoapods.org/?q=KSPhotoBrowser)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS%208.0%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;

### A beautiful photo browser with interactive dismissal animation.

![Rotation~](https://raw.github.com/skx926/KSPhotoBrowser/master/Images/Rotation.gif)
![Blur~](https://raw.github.com/skx926/KSPhotoBrowser/master/Images/Blur.gif)
![Scale~](https://raw.github.com/skx926/KSPhotoBrowser/master/Images/Scale.gif)
![Corner~](https://raw.github.com/skx926/KSPhotoBrowser/master/Images/Corner.gif)
![Orientation~](https://raw.github.com/skx926/KSPhotoBrowser/master/Images/Orientation.gif)
![Index~](https://raw.github.com/skx926/KSPhotoBrowser/master/Images/Index.png)


Features
==============
- [x] 4 different interactive dismissal animations (Rotation, Scale, Slide)
- [x] 3 different background styles (Blur Photo, Blur, Black)
- [x] 2 different loading styles (Determinate, Indeterminate)
- [x] 2 different pager styles (Dot, Text)
- [x] Support bounce animation
- [x] Optimized for image which has a very large height
- [x] Can display one or more images by providing either image urls or UIImage objects
- [x] Custom image downloader library support
- [x] Smooth animation with corner radius
- [x] Support both portrait and landscape device orientation
- [ ] Support video browse


Usage
==============
### Display images from urls
```objc
NSArray *urls = @[@"https://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1f12r9ku6wjj20u00mhn22.jpg",
                  @"https://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1f01hkxyjhej20u00jzacj.jpg"];
NSMutableArray *items = @[].mutableCopy;
for (int i = 0; i < urls.count; i++) {
    // Get the large image url
    NSString *url = [urls[i] stringByReplacingOccurrencesOfString:@"bmiddle" withString:@"large"];
    UIImageView *imageView = _imageViews[i];
    KSPhotoItem *item = [KSPhotoItem itemWithSourceView:imageView imageUrl:[NSURL URLWithString:url]];
    [items addObject:item];
}
KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:0];
[browser showFromViewController:self];
```

### Display images from UIImage objects
```objc
NSArray *names = @[@"a.jpg", @"b.jpg"];
NSMutableArray *items = @[].mutableCopy;
for (int i = 0; i < names.count; i++) {
    UIImageView *imageView = _imageViews[i];
    KSPhotoItem *item = [KSPhotoItem itemWithSourceView:imageView image:[UIImage imageNamed:names[i]]];
    [items addObject:item];
}
KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:0];
[browser showFromViewController:self];
```

Installation
==============
### Cocoapods
1. Update cocoapods to the latest version.
2. Add `pod 'KSPhotoBrowser'` to your Podfile.
3. Run `pod install` or `pod update`.
4. Import `KSPhotoBrowser.h`.


### Manually
1. Download all the files of KSPhotoBrowser and add source files to your project.
2. Manually install [SDWebImage](https://github.com/rs/SDWebImage) to your project.
3. Import `KSPhotoBrowser.h`.

### Custom Image Downloader
It use `SDWebImage` as default image downloader, you can also use your custom image downloader like `YYWebImage`, `Kingfisher` and so on.

To use a custom image downloader, you need to create a class and make it conforms to `KSImageManagerProtocol` and implement those methods inside that protocol.

For convenience, I have already created `KSYYImageManager` to support `YYWebImage` as an example in the demo, you can also use it directly.

Finally, just use the code below to set your class to `KSPhotoBrowser` before you use the browser to show images.

```objc
[KSPhotoBrowser setImageManagerClass:KSYYImageManager.class]
```

Requirements
==============
This library requires `iOS 8.0+` and `Xcode 8.0+`.


License
==============
KSPhotoBrowser is provided under the MIT license. See LICENSE file for details.
