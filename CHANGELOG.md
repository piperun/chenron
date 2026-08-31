# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -
## [v1.17.0](https://github.com/piperun/chenron-flutter/compare/e2748a177dc8fc7441a16a6ebf78ce58c0599928..v1.17.0) - 2026-08-31
#### Features
- (**chenron**) link failure toasts to the activity log - ([0d0842a](https://github.com/piperun/chenron-flutter/commit/0d0842a7bd665dfaba3418ecd4bca685056d0496)) - [@piperun](https://github.com/piperun)
#### Build system
- pin Forrest to 0.3.0 - ([c102d44](https://github.com/piperun/chenron-flutter/commit/c102d44b4ac8fc7bb1d0acb3601468e899775193)) - [@piperun](https://github.com/piperun)
- take viewer state from catalog - ([4ba2e11](https://github.com/piperun/chenron-flutter/commit/4ba2e11b0c38b61630fa497cac4176490cb82b2a)) - [@piperun](https://github.com/piperun)
- implement catalog's owner-called source dispose - ([35c0119](https://github.com/piperun/chenron-flutter/commit/35c01191e25e63246aec757bfb8fb131f7232eb4)) - [@piperun](https://github.com/piperun)
- take viewer state from catalog - ([1648743](https://github.com/piperun/chenron-flutter/commit/1648743b509d01e28524c8c9226428eff7af635e)) - [@piperun](https://github.com/piperun)
- pin vibe to its released commit - ([78243bb](https://github.com/piperun/chenron-flutter/commit/78243bb7d4fb5a743fa3e1d3119ffb5a1ba819b7)) - [@piperun](https://github.com/piperun)
- pin vibe to its released commit - ([9c9e76a](https://github.com/piperun/chenron-flutter/commit/9c9e76aa3c2b1f6e4c6ce1852dbf40c10258bbae)) - [@piperun](https://github.com/piperun)
- take vibe from dashpub - ([f320ada](https://github.com/piperun/chenron-flutter/commit/f320adabb74a003e0c795ad84abe1be20bee271b)) - [@piperun](https://github.com/piperun)
- take vibe from dashpub - ([3d420ec](https://github.com/piperun/chenron-flutter/commit/3d420ec9656872454894d3b3a96729309b29ba42)) - [@piperun](https://github.com/piperun)
#### Refactoring
- (**chenron**) consolidate settings under Storage and Import & Export - ([75e4858](https://github.com/piperun/chenron-flutter/commit/75e4858bd66650b16c1bf53cfeb9766490bd94d9)) - [@piperun](https://github.com/piperun)
- (**chenron**) replace UI em-dashes with plain hyphens - ([e2748a1](https://github.com/piperun/chenron-flutter/commit/e2748a177dc8fc7441a16a6ebf78ce58c0599928)) - [@piperun](https://github.com/piperun)
- (**viewer**) name the source type instead of casting to it - ([5a3707a](https://github.com/piperun/chenron-flutter/commit/5a3707afeab7f17e5f3eb445bde7d589ca6321b0)) - [@piperun](https://github.com/piperun)
- adopt Forrest settings navigation - ([4363912](https://github.com/piperun/chenron-flutter/commit/4363912c43d844f03952957e232b71c49d918876)) - [@piperun](https://github.com/piperun)

- - -

## [v1.16.0](https://github.com/piperun/chenron-flutter/compare/2f0c62167d1162f24febf1fcee0bc61b6c50b30c..v1.16.0) - 2026-08-11
#### Features
- (**chenron**) batch large viewer selections - ([b9b34a7](https://github.com/piperun/chenron-flutter/commit/b9b34a788d5a3bbb8c269358714900474949d545)) - [@piperun](https://github.com/piperun)
- (**chenron**) add a bounded viewer page cache - ([1e3402a](https://github.com/piperun/chenron-flutter/commit/1e3402a7517f719698b721c87c350d8207948846)) - [@piperun](https://github.com/piperun)
- (**database**) add bounded viewer queries - ([a015f89](https://github.com/piperun/chenron-flutter/commit/a015f892f1678552c3ab80b64a39ddcbaa08a6a0)) - [@piperun](https://github.com/piperun)
#### Bug Fixes
- (**chenron**) complete shared invalidation flushes - ([420b9ed](https://github.com/piperun/chenron-flutter/commit/420b9ed8aa520bfeb4720746b22b78ca36c9e65a)) - [@piperun](https://github.com/piperun)
- (**chenron**) coordinate viewer invalidations by database - ([f898584](https://github.com/piperun/chenron-flutter/commit/f898584e0fba403dc9468da922fa95ed5b29a034)) - [@piperun](https://github.com/piperun)
- (**chenron**) stabilize viewer summary and live tags - ([b4a7e9f](https://github.com/piperun/chenron-flutter/commit/b4a7e9f4610053cfe0272fcb666e03e8bec2bc62)) - [@piperun](https://github.com/piperun)
- (**chenron**) isolate viewer summary retries - ([0a8cd6f](https://github.com/piperun/chenron-flutter/commit/0a8cd6f1f5911bd6fe3d75540b40fe1daa9ee35c)) - [@piperun](https://github.com/piperun)
- (**chenron**) enforce case-insensitive tag conflicts - ([f4ba3eb](https://github.com/piperun/chenron-flutter/commit/f4ba3eb68743fb744cdc54459e4564b0056ba301)) - [@piperun](https://github.com/piperun)
- (**chenron**) close viewer page source races - ([bcf7940](https://github.com/piperun/chenron-flutter/commit/bcf7940f68b8cc456fc30b75c636aededb3d4c0c)) - [@piperun](https://github.com/piperun)
- (**database**) preserve viewer membership context - ([bbc58e3](https://github.com/piperun/chenron-flutter/commit/bbc58e37f454c1b5aae9b61dc9b344b5c45d02ad)) - [@piperun](https://github.com/piperun)
- enforce bounded viewer operations - ([477addd](https://github.com/piperun/chenron-flutter/commit/477adddaa418e44f28ce5a7cb0c9f88ba57bf658)) - [@piperun](https://github.com/piperun)
- validate viewer bulk lease counts - ([ad51e02](https://github.com/piperun/chenron-flutter/commit/ad51e02124f436535e734895367993f8d6d1d14d)) - [@piperun](https://github.com/piperun)
- align bounded viewer tag and retry behavior - ([2b2e5c2](https://github.com/piperun/chenron-flutter/commit/2b2e5c2cc1107688a7ac3ebc137ce224723a772c)) - [@piperun](https://github.com/piperun)
#### Refactoring
- (**chenron**) virtualize the main viewer - ([0d48f0c](https://github.com/piperun/chenron-flutter/commit/0d48f0c8950e459307fe8e9c5e4b94e8332d94ad)) - [@piperun](https://github.com/piperun)
- (**chenron**) scope viewer state to the mounted page - ([c3dccbb](https://github.com/piperun/chenron-flutter/commit/c3dccbb55797f1adb0111a1a525cd3f92218ac3d)) - [@piperun](https://github.com/piperun)

- - -

## [v1.15.0](https://github.com/piperun/chenron-flutter/compare/a6181b7bb687112f64afad961d16384409acc65f..v1.15.0) - 2026-08-10
#### Features
- (**cache_manager**) define metadata refresh contracts - ([2b4f0ae](https://github.com/piperun/chenron-flutter/commit/2b4f0aef7b949bc26828514dc42d645a8ab66c1f)) - [@piperun](https://github.com/piperun)
- (**chenron**) add bounded metadata HTTP client - ([3812011](https://github.com/piperun/chenron-flutter/commit/3812011ac2e272ea256c8a6092c82535a6229d3a)) - [@piperun](https://github.com/piperun)
- (**chenron**) parse and validate web metadata - ([8a89664](https://github.com/piperun/chenron-flutter/commit/8a89664ab08c31cee2361069400a586226d89ec6)) - [@piperun](https://github.com/piperun)
- (**database**) persist metadata validators and retry state - ([7080fc5](https://github.com/piperun/chenron-flutter/commit/7080fc5e1c460cf7a62427ba24e9bd144c524127)) - [@piperun](https://github.com/piperun)
- surface resilient metadata refresh state - ([7abbf96](https://github.com/piperun/chenron-flutter/commit/7abbf961f8298525dec5cb9e9e1373f6afd96f31)) - [@piperun](https://github.com/piperun)
- bound metadata refresh queues - ([8350507](https://github.com/piperun/chenron-flutter/commit/835050724d55e91848ea68b840897cf064b0a17f)) - [@piperun](https://github.com/piperun)
- persist resilient metadata cache state - ([037cb9a](https://github.com/piperun/chenron-flutter/commit/037cb9af4a4db85f65736baed3db995f1b3b6990)) - [@piperun](https://github.com/piperun)
#### Bug Fixes
- (**cache_manager**) handle short-label host placeholders - ([c9e0dd9](https://github.com/piperun/chenron-flutter/commit/c9e0dd97f8d522928de6364516709cbd1fe9c82a)) - [@piperun](https://github.com/piperun)
- (**cache_manager**) recognize literal host placeholders - ([3efd490](https://github.com/piperun/chenron-flutter/commit/3efd490915a1e298f02cbc6c6ecc1d7b20443bed)) - [@piperun](https://github.com/piperun)
- (**cache_manager**) preserve refresh invariants - ([f3f992e](https://github.com/piperun/chenron-flutter/commit/f3f992e578efd66ec636c0eb58c7d44276c5c692)) - [@piperun](https://github.com/piperun)
- (**chenron**) release metadata response resources - ([87f5a63](https://github.com/piperun/chenron-flutter/commit/87f5a631cd970265560cc547bc7c372829f02bf2)) - [@piperun](https://github.com/piperun)
- (**chenron**) harden metadata quality edge cases - ([c99d84d](https://github.com/piperun/chenron-flutter/commit/c99d84dd7ec4669d7213afd9efa6cbfe3cbed012)) - [@piperun](https://github.com/piperun)
- (**chenron**) handle transitional metadata states - ([9de88b8](https://github.com/piperun/chenron-flutter/commit/9de88b87c52a2e8a635af2c6875cb264869da178)) - [@piperun](https://github.com/piperun)
- (**database**) track migration schema inputs - ([1364b99](https://github.com/piperun/chenron-flutter/commit/1364b99034967c9122a148bd55263b32b3ddb196)) - [@piperun](https://github.com/piperun)
- preserve local retry state after storage errors - ([87b007f](https://github.com/piperun/chenron-flutter/commit/87b007fde30cb220f4ac825f197e715fcb5bab8e)) - [@piperun](https://github.com/piperun)
- serialize metadata retry state transitions - ([0cd35c1](https://github.com/piperun/chenron-flutter/commit/0cd35c16c0aa36155b57eed4372e538ac409d4c9)) - [@piperun](https://github.com/piperun)
#### Documentation
- clarify local diagnostic-data exception - ([41d7911](https://github.com/piperun/chenron-flutter/commit/41d79110d1fbba0c783449a01e55ecefc19d0f10)) - [@piperun](https://github.com/piperun)
- enforce sensitive-data anonymization - ([31ada78](https://github.com/piperun/chenron-flutter/commit/31ada782860174265a7d5186189586310a18559b)) - [@piperun](https://github.com/piperun)
#### Refactoring
- preserve metadata during refresh - ([50bc812](https://github.com/piperun/chenron-flutter/commit/50bc812f83741fbf75c8ec345c2738ba4b9b8b45)) - [@piperun](https://github.com/piperun)

- - -

## [v1.14.4](https://github.com/piperun/chenron-flutter/compare/eb350888d1efa5f976622ecf7545c76029943d02..v1.14.4) - 2026-06-03
#### Bug Fixes
- (**chenron**) apply the configured image cache directory - ([6821442](https://github.com/piperun/chenron-flutter/commit/6821442c057ccc65a004fd5475150bba5be4f13d)) - [@piperun](https://github.com/piperun)
#### Documentation
- (**database**) document the single-writer worker-isolate invariant - ([1bea5f6](https://github.com/piperun/chenron-flutter/commit/1bea5f67a77496347ecd0016074d9427d395ddc7)) - [@piperun](https://github.com/piperun)
#### Refactoring
- (**cache_manager**) make ImageCacheManager an injectable instance - ([c64f084](https://github.com/piperun/chenron-flutter/commit/c64f084ec73719cfeafe6f7b6c479d778e4aa2a0)) - [@piperun](https://github.com/piperun)
- (**cache_manager**) stop re-exporting cached_network_image - ([eb35088](https://github.com/piperun/chenron-flutter/commit/eb350888d1efa5f976622ecf7545c76029943d02)) - [@piperun](https://github.com/piperun)
- (**chenron**) draw stat-card accents from ChartPalette - ([dde8a6f](https://github.com/piperun/chenron-flutter/commit/dde8a6f62a1195164db746a66bd5d83fa0fef5ad)) - [@piperun](https://github.com/piperun)
- (**database**) standardize timestamp storage to canonical UTC - ([4808cf0](https://github.com/piperun/chenron-flutter/commit/4808cf01903a31ef8020a8aae234ae277c33cd03)) - [@piperun](https://github.com/piperun)

- - -

## [v1.14.3](https://github.com/piperun/chenron-flutter/compare/d92740b07bdfce5f86579df3b8120bc7753aa5f1..v1.14.3) - 2026-06-02
#### Bug Fixes
- (**cache_manager**) store cached files under the configured path - ([6ca173c](https://github.com/piperun/chenron-flutter/commit/6ca173c2f0288f0b1401064a026413105ef27d09)) - [@piperun](https://github.com/piperun)
- (**chenron**) show timestamps in the device's local zone - ([39208b1](https://github.com/piperun/chenron-flutter/commit/39208b15d79a36b33bcec8d65184d616e12f794d)) - [@piperun](https://github.com/piperun)
- (**chenron**) folder titles, export errors, save guard, tag color cancel - ([fa51a71](https://github.com/piperun/chenron-flutter/commit/fa51a71de9d3aad945a9ecc54d2fd4d19c64bb30)) - [@piperun](https://github.com/piperun)
- (**chenron**) reset UnifiedItem tag expansion on row recycle - ([2e0b39c](https://github.com/piperun/chenron-flutter/commit/2e0b39c8dec500ba3bd3f45f0e35896819c1dd1a)) - [@piperun](https://github.com/piperun)
- (**chenron**) guard infinite scroll reset race and loader errors - ([8d1329f](https://github.com/piperun/chenron-flutter/commit/8d1329ff3f719b5b71875723252c82aa6596d6d4)) - [@piperun](https://github.com/piperun)
- (**chenron**) guard folder-editor context across async gaps - ([57b0b95](https://github.com/piperun/chenron-flutter/commit/57b0b95c7ff9fd3d721a83a393492fe5bae0e37c)) - [@piperun](https://github.com/piperun)
- (**chenron**) prevent folder parent cycles - ([4e9b0ac](https://github.com/piperun/chenron-flutter/commit/4e9b0ac3cf8fe8744dabed3d18cdb6f87c874c2c)) - [@piperun](https://github.com/piperun)
- (**chenron**) degrade gracefully on corrupt search history - ([3d8f8e4](https://github.com/piperun/chenron-flutter/commit/3d8f8e46973d34ac394680d9ca9c987d96eee35f)) - [@piperun](https://github.com/piperun)
- (**database**) store app-written timestamps in UTC - ([86004f7](https://github.com/piperun/chenron-flutter/commit/86004f751a01cf625027fb696197dfe9573986b2)) - [@piperun](https://github.com/piperun)
- (**database**) add getDescendantFolderIds for folder cycle detection - ([4abd44e](https://github.com/piperun/chenron-flutter/commit/4abd44e8deb5d6820b68484da5c3476c1409e025)) - [@piperun](https://github.com/piperun)
- (**database**) archive outside the write transaction - ([6a046ef](https://github.com/piperun/chenron-flutter/commit/6a046ef22830f4c30cf0d68686e78e37ed014a83)) - [@piperun](https://github.com/piperun)
- (**database**) stamp update triggers at millisecond precision - ([55d53ca](https://github.com/piperun/chenron-flutter/commit/55d53caa915b0e6aa519799421867090f0fd9795)) - [@piperun](https://github.com/piperun)
#### Performance
- (**chenron**) narrow over-scoped SignalBuilder boundaries - ([dd80ce0](https://github.com/piperun/chenron-flutter/commit/dd80ce04199a15936d6aa4695ffac0d84b159c3a)) - [@piperun](https://github.com/piperun)
- (**chenron**) memoize statistics chart aggregations - ([2a390cc](https://github.com/piperun/chenron-flutter/commit/2a390cce40d2ac342200edc744a3bdea26c04a4f)) - [@piperun](https://github.com/piperun)
- (**chenron**) split statistics load by time-range dependency - ([d318be7](https://github.com/piperun/chenron-flutter/commit/d318be7d53b62f08349b1e8df261c59ef73288b0)) - [@piperun](https://github.com/piperun)
- (**database**) bound getAllBackgroundJobs to recent rows - ([85201b1](https://github.com/piperun/chenron-flutter/commit/85201b1a253a1ea298f5bd6cf03ccf8b63244eb5)) - [@piperun](https://github.com/piperun)
- (**vibe**) batch the Nier grid into a single drawPath - ([647e59e](https://github.com/piperun/chenron-flutter/commit/647e59ef856e14c80adf4479fb40ca6c3280b86d)) - [@piperun](https://github.com/piperun)
#### Refactoring
- (**chenron**) consolidate responsive layer to MD3 size classes - ([42be851](https://github.com/piperun/chenron-flutter/commit/42be851df34296ec09407c556b70dbd3a83ea50e)) - [@piperun](https://github.com/piperun)
- (**chenron**) remove dead displayItems and fix theme log - ([e8ec03b](https://github.com/piperun/chenron-flutter/commit/e8ec03bcf5f45c436b79615ab20161b6c8f545a5)) - [@piperun](https://github.com/piperun)
- (**chenron**) drop dead appendRow, mark test-only aggregation seam - ([293099a](https://github.com/piperun/chenron-flutter/commit/293099ae5145592ed988cbb39d98489d0dbf03fc)) - [@piperun](https://github.com/piperun)
- (**vibe**) share Nier pointer and use dart:ui lerpDouble - ([c1a9560](https://github.com/piperun/chenron-flutter/commit/c1a9560a9ae581e824696669fa399a508036ba0d)) - [@piperun](https://github.com/piperun)

- - -

## [v1.14.2](https://github.com/piperun/chenron-flutter/compare/8ba73a03f1552e3e2fa4a3bc802aebb525205e46..v1.14.2) - 2026-06-02
#### Bug Fixes
- (**basedir**) make isDirWritable probe unique and always clean up - ([55125ed](https://github.com/piperun/chenron-flutter/commit/55125ed85ef801dd82d17490bbba2358188731a3)) - [@piperun](https://github.com/piperun)
- (**cache_manager**) stop MetadataService leaking signals and slots - ([690c73b](https://github.com/piperun/chenron-flutter/commit/690c73bb3cdf97e021b361982dee70fc4cbea007)) - [@piperun](https://github.com/piperun)
- (**chenron**) make setState async-safe and dispose a leaked notifier - ([95ff523](https://github.com/piperun/chenron-flutter/commit/95ff523189779aeb2aea1d27eb81c5f1253482c5)) - [@piperun](https://github.com/piperun)
- (**chenron**) correct four UI rendering bugs - ([0dfe307](https://github.com/piperun/chenron-flutter/commit/0dfe3075261c34503a9226742e14250284ca4874)) - [@piperun](https://github.com/piperun)
- (**chenron**) stop ViewerPresenter stacking subscriptions and leaking - ([c85f4f8](https://github.com/piperun/chenron-flutter/commit/c85f4f8078389c05520ac8fd265b0e0e0f4b2bc3)) - [@piperun](https://github.com/piperun)
- (**chenron**) stop duplicating link tag relations on save and import - ([f10a013](https://github.com/piperun/chenron-flutter/commit/f10a013e4649bcdf9984f3a4dfc3309f1137c15c)) - [@piperun](https://github.com/piperun)
- (**database**) type-gate tag joins and make default-folder fallback stable - ([015c74b](https://github.com/piperun/chenron-flutter/commit/015c74b0d3c636b233f151bce1ae0b2be04da103)) - [@piperun](https://github.com/piperun)
- (**database**) preserve background-job fields on status update - ([51c84f1](https://github.com/piperun/chenron-flutter/commit/51c84f176a13bff8b672b067b3b9601c54e300fc)) - [@piperun](https://github.com/piperun)
- (**database**) delete a folder's parent-membership rows on remove - ([c21121e](https://github.com/piperun/chenron-flutter/commit/c21121e50da48783c4b352d5760b4c033efacb1a)) - [@piperun](https://github.com/piperun)
- (**database**) enforce one tag relation per item via unique index - ([8ba73a0](https://github.com/piperun/chenron-flutter/commit/8ba73a03f1552e3e2fa4a3bc802aebb525205e46)) - [@piperun](https://github.com/piperun)
- (**web_archiver**) harden archive client parsing and UTC dates - ([cc25d47](https://github.com/piperun/chenron-flutter/commit/cc25d47dc093b4686e2bf1c46ae9945de393d508)) - [@piperun](https://github.com/piperun)
#### Performance
- (**chenron**) narrow widget rebuild scope - ([2777fa9](https://github.com/piperun/chenron-flutter/commit/2777fa9d62509bc323549ac37bcc80f7ef414b63)) - [@piperun](https://github.com/piperun)
- (**chenron**) decorate-sort items by precomputed key - ([68ec9cf](https://github.com/piperun/chenron-flutter/commit/68ec9cfefab3b3099339282c7e4c356bf700640b)) - [@piperun](https://github.com/piperun)
- (**chenron**) bound image decode to display size - ([1d2d07a](https://github.com/piperun/chenron-flutter/commit/1d2d07a934f10bde475949b3cf759797d121bfe1)) - [@piperun](https://github.com/piperun)
- (**database**) cut redundant queries in tag-add and count paths - ([efcfe05](https://github.com/piperun/chenron-flutter/commit/efcfe05637ac4ff556116d40e98270afc0d9bdb4)) - [@piperun](https://github.com/piperun)
#### Refactoring
- (**chenron**) widget composition and setState cleanups - ([3af179b](https://github.com/piperun/chenron-flutter/commit/3af179b06d5e6be6cd0af30ed1fe5d8686a79995)) - [@piperun](https://github.com/piperun)
- (**chenron**) remove two superseded widgets - ([5346d21](https://github.com/piperun/chenron-flutter/commit/5346d2101fe3b0e93639196f0d06cc0bef950469)) - [@piperun](https://github.com/piperun)
- (**chenron**) make table renderers widgets and null-safe - ([95eba3f](https://github.com/piperun/chenron-flutter/commit/95eba3fc87d570f308c3b423e855ad8b5345b6cb)) - [@piperun](https://github.com/piperun)
- (**chenron**) hoist _buildX helpers to StatelessWidget classes - ([b813e9f](https://github.com/piperun/chenron-flutter/commit/b813e9f06bf3d9b01fd52390838c9d2ce30953db)) - [@piperun](https://github.com/piperun)
- (**database**) drop dead RelationBuilder override and empty stub - ([1903fc7](https://github.com/piperun/chenron-flutter/commit/1903fc7c622732e020a76beb6bfe4974001c8a24)) - [@piperun](https://github.com/piperun)

- - -

## chenron-v1.14.1 - 2026-05-22
#### Bug Fixes
- (**chenron**) persist maximized state and reject garbage window sizes - (c6e84d4) - *piperun*

- - -

## [v1.3.0](https://github.com/piperun/chenron-flutter/compare/280bc7722d309905937a67a6c480abf1a0319bfe..v1.3.0) - 2026-05-23
### Package updates
- [chenron-v1.14.1](apps/chenron) bumped to [chenron-v1.14.1](https://github.com/piperun/chenron-flutter/compare/chenron-v1.14.0..chenron-v1.14.1)
- [chenron_mockups](packages/chenron_mockups) bumped to [chenron_mockups-v0.0.1](https://github.com/piperun/chenron-flutter/compare/3a4459e3d4b97af54131dbe1a22de0da545dbfbd..chenron_mockups-v0.0.1)
### Global changes
#### Features
- (**vibe**) WIP — nier UI overhaul + per-theme settings schema - ([280bc77](https://github.com/piperun/chenron-flutter/commit/280bc7722d309905937a67a6c480abf1a0319bfe)) - [@piperun](https://github.com/piperun)

- - -

## chenron-v1.14.0 - 2026-05-21
#### Features
- (**chenron**) WIP — migrate Settings nav rail to SuperButton - (d8a9f36) - *piperun*
- (**chenron**) WIP — adopt theme-agnostic MinorButton - (ac94c1c) - *piperun*
- (**chenron**) WIP — migrate primary OutlinedButton sites to NierMinorButton - (ac76686) - *piperun*
- (**chenron**) WIP — adopt HoverShadow + NierMinorButton - (a4ba97f) - *piperun*
- (**chenron**) WIP — apply Nier tokens + per-theme settings UI - (f19bb40) - *piperun*
- (**chenron**) consume ShapeTokens for hand-rolled corners - (7a27199) - *piperun*
#### Performance Improvements
- (**chenron**) parallelize SettingsCoordinator initialize - (8c2beb8) - *piperun*
- (**chenron**) split folder-rail counts into fast names + slow counts upgrade - (5f61abe) - *piperun*
- (**chenron**) folder-open + startup latency fixes - (aacac32) - *piperun*

- - -

## chenron-v1.13.1 - 2026-05-20
#### Bug Fixes
- (**chenron**) collapse duplicate ChenronDir enum to silence GetIt warning - (acd0dd0) - *piperun*

- - -

## [v1.2.1](https://github.com/piperun/chenron-flutter/compare/48f4c66301952b4bc2f4a98f942c6b05ef45f859..v1.2.1) - 2026-05-20
### Package updates
- [chenron-v1.13.1](apps/chenron) bumped to [chenron-v1.13.1](https://github.com/piperun/chenron-flutter/compare/chenron-v1.13.0..chenron-v1.13.1)
### Global changes

- - -

## chenron-v1.13.0 - 2026-05-20
#### Refactoring
- (**chenron**) hoist metadata fetch + migrate to MetadataService signals - (62c5808) - *piperun*

- - -

## [v1.2.0](https://github.com/piperun/chenron-flutter/compare/48f4c66301952b4bc2f4a98f942c6b05ef45f859..v1.2.0) - 2026-05-20
### Package updates
- [cache_manager-v0.6.0](packages/cache_manager) bumped to [cache_manager-v0.6.0](https://github.com/piperun/chenron-flutter/compare/cache_manager-v0.5.0..cache_manager-v0.6.0)
### Global changes

- - -

## chenron-v1.12.0 - 2026-05-20
#### Features
- (**chenron**) wire statistics charts to ChartPalette + themed tooltips - (80553fe) - *piperun*
- (**chenron**) polish Growth Trend chart tooltip readability - (7b6b158) - *piperun*
#### Bug Fixes
- (**chenron**) improve folder list selected state contrast - (3f92212) - *piperun*
- (**chenron**) theme picker shows honest selection state - (1ec168d) - *piperun*
- (**chenron**) statistics page polish - (b3de25a) - *piperun*
- (**chenron**) satisfy Flutter 3.44 ListTile assertion in search dialogs - (be6f765) - *piperun*
- (**chenron**) wrap bottom-sheet child in Material to satisfy Flutter 3.44 assertion - (7464a99) - *piperun*

- - -

## [v1.2.0](https://github.com/piperun/chenron-flutter/compare/2552bd5c4e19c095c9565d976354476a9968bac7..v1.2.0) - 2026-05-19
### Package updates
- [vibe-v0.2.0](packages/vibe) bumped to [vibe-v0.2.0](https://github.com/piperun/chenron-flutter/compare/vibe-v0.1.1..vibe-v0.2.0)
- [chenron-v1.12.0](apps/chenron) bumped to [chenron-v1.12.0](https://github.com/piperun/chenron-flutter/compare/chenron-v1.11.0..chenron-v1.12.0)
### Global changes
#### Refactoring
- (**cache_manager**) unify logging on app_logger - ([0988b01](https://github.com/piperun/chenron-flutter/commit/0988b0137e65d69db27d651f125f4b429c92510c)) - [@piperun](https://github.com/piperun)

- - -

## chenron-v1.11.0 - 2026-05-19
#### Features
- (**chenron**) auto-purge activity log on startup with retention setting - (2f0d4cb) - *piperun*
- (**chenron**) add safeWatch + safeAwait error-handling helpers - (16900d0) - *piperun*
#### Bug Fixes
- (**chenron**) reuse the lifecycle ConfigDatabase in _processArchiveQueue - (172fb63) - *piperun*
- (**chenron**) close the 3 remaining stream-error audit OPEN sites - (eb2e8aa) - *piperun*
- (**chenron**) wrap MISSING db awaits with safeAwait across page-level handlers - (c023d97) - *piperun*
- (**chenron**) route the three .listen() stream sites through safeWatch - (fe56c4f) - *piperun*
- (**chenron**) replace SILENT catches in tag/folder pickers with safeAwait - (08d97fd) - *piperun*
- (**chenron**) dispose the SuggestionsOverlay query effect on State.dispose - (89be7e1) - *piperun*
- (**chenron**) guard CreateLinkNotifier signal writes against dispose race - (cf4d49f) - *piperun*
- (**chenron**) bound favicon cache with LRU to prevent unbounded growth - (4273117) - *piperun*
#### Performance Improvements
- (**chenron**) batch activity tracker's two writes into one transaction - (86f4167) - *piperun*
- (**chenron**) move bookmark HTML parse to a background isolate - (05d2765) - *piperun*
- (**chenron**) batch folder_editor save into one transaction - (dfd1db5) - *piperun*
- (**chenron**) collapse N+1 metadata lookup in suggestion_builder - (9713713) - *piperun*
- (**chenron**) bound bulk-validation concurrency and share one HTTP client - (36fef07) - *piperun*
- (**chenron**) route metadata refresh notifications by URL via a dispatcher - (a93af39) - *piperun*
- (**chenron**) memoize FilterableItemDisplay filter+sort with Computed - (894fbd9) - *piperun*
- (**chenron**) reduce per-cell rebuilds in item list/grid views - (7df8116) - *piperun*
- (**database**) add getFoldersByIds; drop N+1 in FolderPersistenceService - (b5a4038) - *piperun*
- (**database**) add watchFoldersWithItemCounts for count-only consumers - (78070f6) - *piperun*
#### Refactoring
- (**chenron**) extract _PathModeTile from PathModeSelector - (a9e2fd4) - *piperun*
- (**chenron**) extract _GlobalSearchBarView from GlobalSearchBar - (eeb3bb6) - *piperun*
- (**chenron**) widget-method cleanup for ActivityLogPage - (4270a5a) - *piperun*
- (**chenron**) split DeleteConfirmationDialog build into 4 widgets - (1d35fca) - *piperun*
- (**chenron**) extract showConfirmDialog helper for confirm/destruct dialogs - (46f575d) - *piperun*
- (**chenron**) extract _ChromeIconButton from FolderHeader _ActionRow - (e1d8e9d) - *piperun*
- (**chenron**) extract SettingsSectionHeader - (4847cdf) - *piperun*
- (**chenron**) rename direct-action methods _on* -> _handle* per CLAUDE.md - (2fce12f) - *piperun*
- (**chenron**) rename files to match their renamed Notifier/Service classes - (c798928) - *piperun*
- (**chenron**) rename Controller/State/Manager classes per CLAUDE.md convention - (9a6a0c2) - *piperun*
- (**chenron**) route semantic Colors.* through theme.colorScheme - (adcc975) - *piperun*
- (**chenron**) replace magic ints/strings with named DB enums + constants - (0102f5f) - *piperun*
- (**chenron**) consolidate item-type enums on FolderItemType - (fa785aa) - *piperun*
- <span style="background-color: #d73a49; color: white; padding: 2px 6px; border-radius: 3px; font-weight: bold; font-size: 0.85em;">BREAKING</span>(**database**) trim umbrella + drop main.dart shim - (3f4123e) - *piperun*
- <span style="background-color: #d73a49; color: white; padding: 2px 6px; border-radius: 3px; font-weight: bold; font-size: 0.85em;">BREAKING</span>(**database**) replace 4 ConfigDB lookup tables with intEnum (v5) - (f1ad893) - *piperun*
- (**database**) split DB handler into DatabaseLifecycle + AppFileService - (5b101b7) - *piperun*
- (**database**) canonicalize on database.dart, demote main.dart to shim - (9ed8d08) - *piperun*
- (**settings**) migrate theme UI + delete ConfigController (Phases 8+9) - (883b9ea) - *piperun*
- (**settings**) migrate backup + data UIs off ConfigController (Phases 6+7) - (c308b02) - *piperun*
- (**settings**) migrate display + cache UIs off ConfigController (Phase 5) - (f198c95) - *piperun*
- (**settings**) migrate archive UI off ConfigController bridge (Phase 4) - (29b147b) - *piperun*
- (**settings**) SettingsCoordinator + bridge ConfigController (Phase 3) - (1a144aa) - *piperun*
- (**settings**) add Backup + Theme section notifiers (Phase 2) - (b759f57) - *piperun*
- (**settings**) introduce per-section notifiers (Archive/Display/Database) - (4ca9f5d) - *piperun*
- <span style="background-color: #d73a49; color: white; padding: 2px 6px; border-radius: 3px; font-weight: bold; font-size: 0.85em;">BREAKING</span>locator-manage three static singletons - (f195a96) - *piperun*

- - -

## chenron-v1.10.0 - 2026-05-09
#### Features
- (**chenron**) log metadata fetches to the activity log - (4372553) - *piperun*
- (**chenron**) UX cleanups across activity log icon, search, settings, link creation - (4388c30) - *piperun*
#### Refactoring
- generalize archive_jobs table into background_jobs - (0a99b8d) - *piperun*

- - -

## [v1.1.0](https://github.com/piperun/chenron-flutter/compare/70f692f96e3e3337d8f7b1daae37df4cc7f162bc..v1.1.0) - 2026-05-09
### Package updates
- [chenron-v1.10.0](apps/chenron) bumped to [chenron-v1.10.0](https://github.com/piperun/chenron-flutter/compare/chenron-v1.9.0..chenron-v1.10.0)
- [cache_manager-v0.4.0](packages/cache_manager) bumped to [cache_manager-v0.4.0](https://github.com/piperun/chenron-flutter/compare/cache_manager-v0.3.0..cache_manager-v0.4.0)
### Global changes
#### Features
- add window_manager for persistent window sizing - ([54a9edc](https://github.com/piperun/chenron-flutter/commit/54a9edc1539bc0a18824b4ab66327929f7563830)) - [@piperun](https://github.com/piperun)
#### Bug Fixes
- update folder editor test for standardized snackbar text - ([3bd8d4c](https://github.com/piperun/chenron-flutter/commit/3bd8d4c2288bd2ea2442e3927945c338b8585332)) - [@piperun](https://github.com/piperun)
#### Documentation
- add versioning rules comment to cog.toml - ([f8c48fc](https://github.com/piperun/chenron-flutter/commit/f8c48fc673b8ce5bae0414657d21bcc8689ddc85)) - [@piperun](https://github.com/piperun)
- add README - ([70f692f](https://github.com/piperun/chenron-flutter/commit/70f692f96e3e3337d8f7b1daae37df4cc7f162bc)) - [@piperun](https://github.com/piperun)

- - -

## chenron-v1.9.0 - 2026-03-29
#### Features
- (**chenron**) add activity log page with filterable archive queue UI - (68a60b6) - *piperun*
- (**database**) trigger archive queue processing on enqueue - (7f6b48d) - *piperun*
- add cache logging to MetadataFactory - (4583086) - *piperun*
#### Bug Fixes
- display toggle popup, save button reactivity, and showCopyLink wiring - (5005f50) - *piperun*
- swap back and home button order in folder viewer - (9410bdb) - *piperun*

- - -

## chenron-v1.8.1 - 2026-03-25
#### Features
- (**chenron**) add activity log page with filterable archive queue UI - (68a60b6) - *piperun*

- - -

## chenron-v1.8.0 - 2026-03-25
#### Features
- wire archive queue processor into app startup - (2719b38) - *piperun*
- integrate startup refresh scheduler into MetadataFactory - (3f17f00) - *piperun*
- integrate change detection and adaptive TTL into MetadataFactory fetch flow - (aaaf197) - *piperun*
- extend persistence interface and bridge for adaptive TTL fields - (18c69a3) - *piperun*
#### Performance Improvements
- single-pass filtering and add DB indexes - (1f8a6f5) - *piperun*
- parallelize DB queries and cache static RegExp - (044b67c) - *piperun*

- - -

## chenron-v1.7.0 - 2026-02-19
#### Features
- improve collapsed navigation rail UX - (640f799) - *piperun*

- - -

## chenron-v1.6.0 - 2026-02-19
#### Features
- show sub-category icons when settings rail is collapsed - (2f5c3b0) - *piperun*
#### Bug Fixes
- reject scheme-only URLs in isValidUrlFormat - (6b334ed) - *piperun*

- - -

## chenron-v1.5.2 - 2026-02-19
#### Bug Fixes
- use sell icon for tags and reject video URLs in og:image - (25216b4) - *piperun*
#### Performance Improvements
- optimize cache computation, batch queries, and FutureBuilder - (9ff81d2) - *piperun*
#### Refactoring
- decouple shared code from global signals and locator - (f1991f5) - *piperun*

- - -

## chenron-v1.5.1 - 2026-02-18
#### Bug Fixes
- remove dead code and unused parameters - (8cadd0a) - *piperun*
- prevent RenderFlex overflow in card mode content - (7ea6d28) - *piperun*
#### Refactoring
- split item_toolbar into focused component files - (a7be8a2) - *piperun*
- split item_detail_dialog into focused component files - (3e17761) - *piperun*
- extract PathModeSelector for settings path modes - (d62cfb2) - *piperun*
- extract CopyFeedbackMixin from footer and URL bar - (2061ea1) - *piperun*
- extract MetadataLifecycleMixin from viewer components - (b21f5d7) - *piperun*
- extract shared ItemEmptyState and remove duplicate URL launch - (2a27ebd) - *piperun*
- unify CardItem into UnifiedItem - (88725d6) - *piperun*

- - -

## chenron-v1.5.0 - 2026-02-18
#### Features
- split cache clearing into images and metadata - (cafc270) - *piperun*
#### Bug Fixes
- toolbar alignment and settings tags icon - (5fc11d1) - *piperun*
#### Refactoring
- replace widget methods with proper widget classes - (92dae43) - *piperun*

- - -

Changelog generated by [cocogitto](https://github.com/cocogitto/cocogitto).