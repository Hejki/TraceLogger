// Copyright (c) 2019 Hejki

import Foundation

/// see: https://stackoverflow.com/questions/27356716/how-can-i-format-string-with-fixed-length-in-swift
extension String {

    // nested `struct` which is needed
    // to keep the `baseAdress` pointer valid (see (*))
    struct CString: CVarArg {
        // needed to conform to `CVarArg`
        var _cVarArgEncoding: [Int] = []

        // needed to keep the `baseAdress` pointer valid (see (*))
        var cstring: ContiguousArray<CChar> = []

        init(string: String) {
            // is essentially just a (special) `Array`
            cstring = string.utf8CString

            self._cVarArgEncoding = cstring.withUnsafeBufferPointer {
                // use the `_cVarArgEncoding` of the first Buffer address (*)
                $0.baseAddress!._cVarArgEncoding
            }
        }
    }

    // you only need to use this property (`c` stands for `CString`)
    // e.g.: String(format: "%s", "test".c)
    var cString: CString {
        return CString(string: self)
    }
}
