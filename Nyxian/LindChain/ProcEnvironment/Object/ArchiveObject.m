/*
 Copyright (C) 2025 cr4zyengineer

 This file is part of Nyxian.

 Nyxian is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Nyxian is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Nyxian. If not, see <https://www.gnu.org/licenses/>.
*/

#import <LindChain/ProcEnvironment/Object/ArchiveObject.h>
#import <LindChain/Utils/Zip.h>

@implementation ArchiveObject

- (instancetype)initWithDirectory:(NSString *)path
{
    // First we create a temporary zip archive
    _temporaryZipArchivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", [[NSUUID UUID] UUIDString]]];
    if(!zipDirectoryAtPath(path, _temporaryZipArchivePath, YES)) return nil;
    
    // Now if successful we open that temporary zip archive
    self = [super initWithPath:_temporaryZipArchivePath];
    return self;
}

- (instancetype)initWithArchive:(NSString *)path
{
    self = [super initWithPath:path];
    return self;
}

- (NSString*)extractArchive
{
    NSString *destinationPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [[NSUUID UUID] UUIDString]]];
    unzipArchiveFromFileDescriptor(self.fd, destinationPath);
    return destinationPath;
}

- (void)deinit
{
    [super deinit];
    if(_temporaryZipArchivePath)
    {
        [[NSFileManager defaultManager] removeItemAtPath:_temporaryZipArchivePath error:nil];
    }
}

@end
