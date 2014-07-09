//
//  EditImageHelper.swift
//  Image Editor
//
//  Created by Tatsuya Suganuma on 2014/07/09.
//  Copyright (c) 2014年 redmorado. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import QuartzCore

class EditImageHelper : NSObject {
    
    class func resize(img:UIImage, size:CGSize, fill:Bool = false, quality:CGInterpolationQuality = kCGInterpolationDefault) -> UIImage{
            
        // 取得した画像の縦サイズ、横サイズを取得する
        let imageW:CGFloat = img.size.width;
        let imageH:CGFloat = img.size.height;
        
        // リサイズする倍率を作成する。
        let scaleWidth:CGFloat = size.width / img.size.width;
        let scaleHeight:CGFloat = size.height / img.size.height;
        let scale:CGFloat = fill ?
            scaleWidth > scaleHeight ? scaleWidth : scaleHeight :
            scaleWidth < scaleHeight ? scaleWidth : scaleHeight;
        
        // 比率に合わせてリサイズする。
        let resizedSize:CGSize = CGSizeMake(imageW * scale, imageH * scale);
        UIGraphicsBeginImageContext(resizedSize);
        CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), quality);
        img.drawInRect(CGRectMake(0, 0, resizedSize.width, resizedSize.height));
        let resizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resizedImage;
    }
    
    
    
    // 中心点からトリミング
    // TODO: UIImageのorientationによって、向きがおかしくなる。autoRotateを先に実行すること。
    class func centerCrop(img:UIImage, size:CGSize) -> UIImage {
        
        let rect:CGRect = CGRectMake( (img.size.width - size.width)/2, (img.size.height - size.height)/2, size.width, size.height);
        let cgImage:CGImageRef = CGImageCreateWithImageInRect(img.CGImage, rect);
        let result:UIImage = UIImage(CGImage: cgImage);
        
        return result;
    }
    
    
    
    // 画像の回転
    class func autoRotate(original:UIImage) -> UIImage{
        
        let orientation:UIImageOrientation = original.imageOrientation;
        let img:UIImage = UIImage(CGImage: original.CGImage, scale: original.scale, orientation: UIImageOrientation.Up);
        
        var contextSize:CGSize = img.size;
        if orientation == UIImageOrientation.Left || orientation == UIImageOrientation.Right {
            contextSize = CGSizeMake(img.size.height, img.size.width);
        }
        
        NSLog("\(orientation == UIImageOrientation.Right)");
        
        // グラフィック機能で編集するためのオブジェクトを取得する
        let imgRef:CGImageRef = img.CGImage;
        
        // コンテキストの編集を開始する
        UIGraphicsBeginImageContext(contextSize);
        // グラフィック編集用のコンテキストを作成
        let context:CGContextRef = UIGraphicsGetCurrentContext();
        
        // 画像の拡大・縮小。マイナスを指定する反転。（デフォルトで上下反転されているのを直す）
        CGContextScaleCTM(context, 1.0, -1.0);
        
        
        // 回転処理を行う
        if orientation == UIImageOrientation.Up {
            CGContextTranslateCTM(context, 0, contextSize.height);
            CGContextRotateCTM(context, 0);
        } else if orientation == UIImageOrientation.Down {
            CGContextTranslateCTM(context, contextSize.width, 0);
            CGContextRotateCTM(context, CGFloat(M_PI));
        } else if orientation == UIImageOrientation.Left {
            CGContextTranslateCTM(context, contextSize.height, img.size.width);
            CGContextRotateCTM(context, CGFloat(M_PI_2));
        } else if orientation == UIImageOrientation.Right {
            CGContextRotateCTM(context, CGFloat(-M_PI_2));
        }
        
        // 回転させて画像をRAM上に描画（画面上ではない）
        CGContextDrawImage(context, CGRectMake(0, 0, img.size.width, img.size.height), imgRef);
        
        // 現在描画しているUIImageオブジェクトを取得
        let result:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        // コンテキストの編集を終了する
        UIGraphicsEndImageContext();
        
        return result;
    }
    
    
    // CALayerからUIImageに変換
    class func imageFromLayer(layer:CALayer, quality:CGInterpolationQuality = kCGInterpolationDefault) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 2);
    
        CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), quality);
        layer.renderInContext(UIGraphicsGetCurrentContext());
        let outputImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
    
        UIGraphicsEndImageContext();
    
        return outputImage;
    }
}
