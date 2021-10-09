

import Foundation
import AVFoundation


extension AVAsset {
    
    func fixedComposition() -> AVMutableVideoComposition? {
        let videoComposition = AVMutableVideoComposition()

        let degress = getVideoDegress()
        
        var translateToCenter: CGAffineTransform
        var mixedTransform: CGAffineTransform
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        guard let videoTrack = self.tracks(withMediaType: .video).first else { return nil }
        
        let roateInstruction = AVMutableVideoCompositionInstruction()
        roateInstruction.timeRange = CMTimeRangeMake(start: .zero, duration: self.duration)
        let roateLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        if degress == 0 {
            translateToCenter = CGAffineTransform(translationX: 0.0, y: 0.0);
            mixedTransform = translateToCenter.rotated(by: 0);
            videoComposition.renderSize =  CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
            roateLayerInstruction.setTransform(mixedTransform, at: .zero)
        } else if degress == 90 {
         
            translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.height, y: 0.0);
            mixedTransform = translateToCenter.rotated(by: .pi / 2);
            videoComposition.renderSize =  CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
            roateLayerInstruction.setTransform(mixedTransform, at: .zero)
        } else if degress == 180 {
    
            translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.width, y: videoTrack.naturalSize.height);
            mixedTransform = translateToCenter.rotated(by: .pi);
            videoComposition.renderSize =  CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
            roateLayerInstruction.setTransform(mixedTransform, at: .zero)
        } else if degress == 270 {
  
            translateToCenter = CGAffineTransform(translationX: 0.0, y: videoTrack.naturalSize.width);
            mixedTransform = translateToCenter.rotated(by: .pi/2*3.0);
            videoComposition.renderSize =  CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
            roateLayerInstruction.setTransform(mixedTransform, at: .zero)
        }
        
        roateInstruction.layerInstructions = [roateLayerInstruction]

        videoComposition.instructions = [roateInstruction]
        
        return videoComposition
    }

    private func getVideoDegress() -> Int {
        guard let videoTrack = self.tracks(withMediaType: .video).first else { return 0 }
        let t = videoTrack.preferredTransform
        if t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0 {
            // Portrait
            return 90;
        } else if t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0 {
            // PortraitUpsideDown
            return 270;
        } else if t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0 {
            // LandscapeRight
            return 0;
        } else if t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0 {
            // LandscapeLeft
            return 180;
        }
        return 0
    }
    
}


