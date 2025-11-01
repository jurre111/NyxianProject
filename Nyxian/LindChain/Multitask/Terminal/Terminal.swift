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

import Foundation
import SwiftTerm
import SwiftUI
import UIKit

// use always the same pipe
@objc class NyxianTerminal: TerminalView, TerminalViewDelegate {
    var title: String
    
    var stdoutHandle: FileHandle
    var stdinHandle: FileHandle
    
    @objc public init (
        frame: CGRect,
        title: String,
        stdoutFD: Int32,
        stdinFD: Int32
    ){
        self.title = title
        
        self.stdoutHandle = FileHandle(fileDescriptor: stdoutFD, closeOnDealloc: true)
        self.stdinHandle = FileHandle(fileDescriptor: stdinFD, closeOnDealloc: true)
        
        super.init(frame: frame)
        
        self.isOpaque = false;
        self.terminalDelegate = self
        self.backgroundColor = .systemBackground
        self.nativeForegroundColor = gibDynamicColor(light: .label, dark: self.nativeForegroundColor)
        self.caretTextColor = .label
        self.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        _ = self.becomeFirstResponder()
        
        stdoutHandle.readabilityHandler = { [weak self] fileHandle in
            let logData = fileHandle.availableData
            if !logData.isEmpty, var logString = String(data: logData, encoding: .utf8) {
                logString = logString.replacingOccurrences(of: "\r", with: "\n\r")
                if let normalizedData = logString.data(using: .utf8) {
                    let normalizedByteArray = Array(normalizedData)
                    let d = normalizedByteArray[...]
                    let sliced = Array(d) [0...]
                    let blocksize = 1024
                    var next = 0
                    let last = sliced.endIndex
                    
                    while next < last {
                        let end = min (next+blocksize, last)
                        let chunk = sliced [next..<end]
                        
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            self.feed(byteArray: chunk)
                        }
                        next = end
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clipboardCopy(source: SwiftTerm.TerminalView, content: Data) {
        
    }
    
    func scrolled(source: SwiftTerm.TerminalView, position: Double) {
        
    }
    
    func setTerminalTitle(source: SwiftTerm.TerminalView, title: String) {
        self.title = title
    }
    
    func sizeChanged(source: SwiftTerm.TerminalView, newCols: Int, newRows: Int) {
        //tcom_set_size(Int32(newRows), Int32(newCols))
    }
    
    func hostCurrentDirectoryUpdate(source: SwiftTerm.TerminalView, directory: String?) {
        
    }
    
    func send(source: SwiftTerm.TerminalView, data: ArraySlice<UInt8>) {
        var array = Array(data)
        write(stdinHandle.fileDescriptor, &array, array.count)
    }
    
    func requestOpenLink(source: SwiftTerm.TerminalView, link: String, params: [String : String]) {
        
    }
    
    func rangeChanged(source: SwiftTerm.TerminalView, startY: Int, endY: Int) {
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        
        if self.isFirstResponder {
            _ = self.resignFirstResponder()
            _ = self.becomeFirstResponder()
        }
    }
}

@objc class TerminalViewController: UIViewController {
    let terminalView: NyxianTerminal
    var bottomConstraint: NSLayoutConstraint!
    
    @objc public init (
        title: String,
        stdoutFD: Int32,
        stdinFD: Int32
    ){
        terminalView = NyxianTerminal(frame: CGRectZero, title: title, stdoutFD: stdoutFD, stdinFD: stdinFD)
        
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.terminalView)
        
        self.terminalView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.terminalView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.terminalView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.terminalView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.terminalView.keyboardLayoutGuide.topAnchor.constraint(equalTo: self.terminalView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
}
