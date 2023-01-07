# エラー対応
- edk2のclone後
    ```
    git clone https://github.com/tianocore/edk2.git
    cd edk2
    git submodule update --init
    cd ..
    ```
  
# EDK2のビルド
```
cd edk2
ln -s ../loader ./
. edksetup.sh
build
```

# 全体の実行
```
make
```

