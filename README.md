# yaizawa_misc
思いつきで作った雑多なものをおもちゃ箱的に置いておきます。
BSDライセンスにしているので、ご自由にお使いください。
(FreeBSD使いなので、なんとなくMITではなくBSDにしている)

## 置いてあるもの
### OpenSCAD
#### menger_sponge.scad

Twitterでメンガーのスポンジを3Dプリンタで出力している方を見かけたので、OpenSCADで再現してみました。
変数LENで辺の長さ (mm) を、DIMで再帰の深さを指定してください。
DIM=0で面ごとに穴が1個、DIM=1で大きいの1個+小さいの8個…といった具合に空いている形になります。
ThinkPad X230 (Intel HD Graphics 4000) だとDIM=3以上にするとOpenSCADが帰ってこなくなりました…。

![image](https://user-images.githubusercontent.com/16421395/152648218-53931d0a-9358-469c-b453-913cf47c4b97.png)

