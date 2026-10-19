# ローカル環境で不足したライセンスファイルの調査

PyPI に登録された該当バージョンのソース配布物からライセンス候補を抽出し、配布物の SHA-256 を照合した。ビルドに含まれる全依存物の監査完了を意味しない。

- colorspacious 1.1.2: [PyPI sdist](https://files.pythonhosted.org/packages/75/e4/aa41ae14c5c061205715006c8834496d86ec7500f1edda5981f0f0190cc6/colorspacious-1.1.2.tar.gz), SHA-256 `5e9072e8cdca889dac445c35c9362a22ccf758e97b00b79ff0d5a7ba3e11b618`, 候補 1件
- pyfulgur 0.40.0: [PyPI sdist](https://files.pythonhosted.org/packages/69/b0/74be65477b9ef9aaa3682c068ba4663159ba49cdc73501477e50651d3ae5/pyfulgur-0.40.0.tar.gz), SHA-256 `36fc36fd008b1eaee9e0c01d60b8b291733daf82dc7ed26127fb71155572a059`, sdist内候補 0件。対応する[上流タグ v0.40.0](https://github.com/fulgur-rs/fulgur/tree/v0.40.0)の `LICENSE-MIT` と `LICENSE-APACHE` をGitHubのファイル取得機能で収集。
- pyobjc-core 12.2.2: [PyPI sdist](https://files.pythonhosted.org/packages/a5/78/abc4ce5920305780aeb36b4067a86253378b36e29ba96673a3deb02eb03a/pyobjc_core-12.2.2.tar.gz), SHA-256 `3906452339cd06a3bb07df103c2511d4cb0f7a22d8771c0b802eba15d9a642b6`, 候補 2件
- pyobjc-framework-libdispatch 12.2.2: [PyPI sdist](https://files.pythonhosted.org/packages/f0/76/e40db30142b551790e5ab208e74de04cfc70823177a702c8c9e3f5e73034/pyobjc_framework_libdispatch-12.2.2.tar.gz), SHA-256 `7cb799a7c5766cc1b68b68655a02c950646adfd2a743b7cbe8e4a04a51c44ecb`, 候補 1件
- pyserial 3.5: [PyPI sdist](https://files.pythonhosted.org/packages/1e/7d/ae3f0a63f41e4d2f6cb66a5b57197850f919f59e558159a4dd3a818f5082/pyserial-3.5.tar.gz), SHA-256 `3c77e014170dfffbd816e6ffc205e9842efb10be9f58ec16d3e8675b4925cddb`, 候補 1件
