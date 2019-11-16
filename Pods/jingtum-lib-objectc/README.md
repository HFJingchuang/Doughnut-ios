# jingtum-lib-objective-c
The jingtum-lib-objective-c library to be used for interacting with jingtum blockchain network. 
This is the objective-c version.

### Jingtum introduction 

Jingtum is one of the most mature block chain platforms at home and abroad. It is the only block chain technology that has been tested by large-scale applications. Jingtum company has built up a well connected block chain platform (public chain), which is located in the development of a block chain ecosystem with various applications. [website][1]



## Source code  
* src/jingtum-lib - The source codes of jingtum lib.
* src/ViewController.m - The tests for jingtum lib.
* Samples - The samples to use the jingtum lib.
* docs - The documentation for the jingtum lib.

## Supporting Environment
* MacOS 

## Development Environment
* MacOS
* Xcode

## References:
The following libraries are referenced.
* SocketRocket (https://github.com/facebook/SocketRocket)
* CoreBitcoin (https://github.com/oleganza/CoreBitcoin)

## Installation
After download this sourcecode, we should run 
```ruby
pod install
```
to download the nessessary libraries


Also jingtum-lib-objectc is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "jingtum-lib-objectc"
```
### Attention 
After run 
```ruby
pod install
```
we get all the needed libraries, then we should modify the file: Pods/CoreBitcoin/CoreBitcoin/BTCBase58.m
from

```ruby
static const char* BTCBase58Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
```
to

```ruby
static const char* BTCBase58Alphabet = "jpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65rkm8oFqi1tuvAxyz";
```

<br>

## Summary
The jingtum-lib-objective-c library is based on the ws protocol to connect with jingtum system. 
The Remote class provides public APIs to create two kinds of objects: Request object by GET
method, and Transaction object by POST method. And then can submit data to server through 
Submit() method.

## How to use
1) Create a new instance of Remote class.  
```
    Remote *remote = [Remote instance];
```

2) Connect to server.  
```
    [remote connectWithURLString:@"ws://123.57.219.57:5020" local_sign:true];
```

3) Close the connection
```
    remote.Disconnect();
```

### Contributing //贡献，在此可以添加一些联系方式比如说 qq 群之类的
Please feel free to send me pull requests or And other ways of contact to add links.<br>
QQ : 3107251779<br>

### Licensing //许可
jingtum-lib-objective-c is released under the terms of the MIT license. See COPYING for more information or see [MIT](https://opensource.org/licenses/MIT)

