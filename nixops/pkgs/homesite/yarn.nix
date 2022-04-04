{ fetchurl, fetchgit, linkFarm, runCommand, gnutar }: rec {
  offline_cache = linkFarm "offline" packages;
  packages = [
    {
      name = "_babel_code_frame___code_frame_7.14.5.tgz";
      path = fetchurl {
        name = "_babel_code_frame___code_frame_7.14.5.tgz";
        url  = "https://registry.yarnpkg.com/@babel/code-frame/-/code-frame-7.14.5.tgz";
        sha1 = "23b08d740e83f49c5e59945fbf1b43e80bbf4edb";
      };
    }
    {
      name = "_babel_helper_validator_identifier___helper_validator_identifier_7.14.5.tgz";
      path = fetchurl {
        name = "_babel_helper_validator_identifier___helper_validator_identifier_7.14.5.tgz";
        url  = "https://registry.yarnpkg.com/@babel/helper-validator-identifier/-/helper-validator-identifier-7.14.5.tgz";
        sha1 = "d0f0e277c512e0c938277faa85a3968c9a44c0e8";
      };
    }
    {
      name = "_babel_highlight___highlight_7.14.5.tgz";
      path = fetchurl {
        name = "_babel_highlight___highlight_7.14.5.tgz";
        url  = "https://registry.yarnpkg.com/@babel/highlight/-/highlight-7.14.5.tgz";
        sha1 = "6861a52f03966405001f6aa534a01a24d99e8cd9";
      };
    }
    {
      name = "_fortawesome_fontawesome_free___fontawesome_free_6.1.1.tgz";
      path = fetchurl {
        name = "_fortawesome_fontawesome_free___fontawesome_free_6.1.1.tgz";
        url  = "https://registry.yarnpkg.com/@fortawesome/fontawesome-free/-/fontawesome-free-6.1.1.tgz";
        sha1 = "bf5d45611ab74890be386712a0e5d998c65ee2a1";
      };
    }
    {
      name = "_parcel_bundler_default___bundler_default_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_bundler_default___bundler_default_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/bundler-default/-/bundler-default-2.4.1.tgz";
        sha1 = "a158fe63d99e38865db8353132bd1b2ff62ab47a";
      };
    }
    {
      name = "_parcel_cache___cache_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_cache___cache_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/cache/-/cache-2.4.1.tgz";
        sha1 = "94322d6de5b9ccb18d58585c267022f47a6315d3";
      };
    }
    {
      name = "_parcel_codeframe___codeframe_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_codeframe___codeframe_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/codeframe/-/codeframe-2.4.1.tgz";
        sha1 = "57dcedb0326ca120241d2f272b84019009350b20";
      };
    }
    {
      name = "_parcel_compressor_raw___compressor_raw_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_compressor_raw___compressor_raw_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/compressor-raw/-/compressor-raw-2.4.1.tgz";
        sha1 = "0bd2cb6fe02ae910e4e25f4db7b08ec1c1a52395";
      };
    }
    {
      name = "_parcel_config_default___config_default_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_config_default___config_default_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/config-default/-/config-default-2.4.1.tgz";
        sha1 = "4b498b916dd9e47d49d4ad414a4139846a3e11bd";
      };
    }
    {
      name = "_parcel_core___core_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_core___core_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/core/-/core-2.4.1.tgz";
        sha1 = "436b219769f273af299deb81f576be5b528c7e27";
      };
    }
    {
      name = "_parcel_css_darwin_arm64___css_darwin_arm64_1.7.4.tgz";
      path = fetchurl {
        name = "_parcel_css_darwin_arm64___css_darwin_arm64_1.7.4.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/css-darwin-arm64/-/css-darwin-arm64-1.7.4.tgz";
        sha1 = "9d173f8d9a3f6dec34e49999654ba091121f1f22";
      };
    }
    {
      name = "_parcel_css_darwin_x64___css_darwin_x64_1.7.4.tgz";
      path = fetchurl {
        name = "_parcel_css_darwin_x64___css_darwin_x64_1.7.4.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/css-darwin-x64/-/css-darwin-x64-1.7.4.tgz";
        sha1 = "e36f8a4c941c9059d6fc96e1f52c8022f04c32ef";
      };
    }
    {
      name = "_parcel_css_linux_arm_gnueabihf___css_linux_arm_gnueabihf_1.7.4.tgz";
      path = fetchurl {
        name = "_parcel_css_linux_arm_gnueabihf___css_linux_arm_gnueabihf_1.7.4.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/css-linux-arm-gnueabihf/-/css-linux-arm-gnueabihf-1.7.4.tgz";
        sha1 = "783407f8179164e6555c9498436bc0e8d1c6c4e3";
      };
    }
    {
      name = "_parcel_css_linux_arm64_gnu___css_linux_arm64_gnu_1.7.4.tgz";
      path = fetchurl {
        name = "_parcel_css_linux_arm64_gnu___css_linux_arm64_gnu_1.7.4.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/css-linux-arm64-gnu/-/css-linux-arm64-gnu-1.7.4.tgz";
        sha1 = "34ed91540fe31001a835f7f5dfc86c90419fb2db";
      };
    }
    {
      name = "_parcel_css_linux_arm64_musl___css_linux_arm64_musl_1.7.4.tgz";
      path = fetchurl {
        name = "_parcel_css_linux_arm64_musl___css_linux_arm64_musl_1.7.4.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/css-linux-arm64-musl/-/css-linux-arm64-musl-1.7.4.tgz";
        sha1 = "3937fdadb0581e96b9f76a37713241b35a3250fa";
      };
    }
    {
      name = "_parcel_css_linux_x64_gnu___css_linux_x64_gnu_1.7.4.tgz";
      path = fetchurl {
        name = "_parcel_css_linux_x64_gnu___css_linux_x64_gnu_1.7.4.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/css-linux-x64-gnu/-/css-linux-x64-gnu-1.7.4.tgz";
        sha1 = "ee883af8a97b99519c581cb2971c414e962a6ae1";
      };
    }
    {
      name = "_parcel_css_linux_x64_musl___css_linux_x64_musl_1.7.4.tgz";
      path = fetchurl {
        name = "_parcel_css_linux_x64_musl___css_linux_x64_musl_1.7.4.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/css-linux-x64-musl/-/css-linux-x64-musl-1.7.4.tgz";
        sha1 = "fd14e88683026665543bc48dee138edc553fcf75";
      };
    }
    {
      name = "_parcel_css_win32_x64_msvc___css_win32_x64_msvc_1.7.4.tgz";
      path = fetchurl {
        name = "_parcel_css_win32_x64_msvc___css_win32_x64_msvc_1.7.4.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/css-win32-x64-msvc/-/css-win32-x64-msvc-1.7.4.tgz";
        sha1 = "ed6dfb63600610ba555124262d84fa537ee7e6a4";
      };
    }
    {
      name = "_parcel_css___css_1.7.4.tgz";
      path = fetchurl {
        name = "_parcel_css___css_1.7.4.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/css/-/css-1.7.4.tgz";
        sha1 = "87b522681a5527ad38baec4193a26a94fde37a5e";
      };
    }
    {
      name = "_parcel_diagnostic___diagnostic_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_diagnostic___diagnostic_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/diagnostic/-/diagnostic-2.4.1.tgz";
        sha1 = "edb275699b543f71cf933bea141a3165ad919a0d";
      };
    }
    {
      name = "_parcel_events___events_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_events___events_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/events/-/events-2.4.1.tgz";
        sha1 = "6e1ba26d55f7a2d6a7491e0901d287de3e471e99";
      };
    }
    {
      name = "_parcel_fs_search___fs_search_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_fs_search___fs_search_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/fs-search/-/fs-search-2.4.1.tgz";
        sha1 = "ae195107895f366183ed0a3fa34bd4eeeaf3dfef";
      };
    }
    {
      name = "_parcel_fs___fs_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_fs___fs_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/fs/-/fs-2.4.1.tgz";
        sha1 = "49e22a8f8018916a4922682e8e608256752c9692";
      };
    }
    {
      name = "_parcel_graph___graph_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_graph___graph_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/graph/-/graph-2.4.1.tgz";
        sha1 = "33c8d370603e898d1ef6e99b4936b90c45d6d76c";
      };
    }
    {
      name = "_parcel_hash___hash_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_hash___hash_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/hash/-/hash-2.4.1.tgz";
        sha1 = "475ecec62b08dbd21dddb62d6dc5b9148a6e5fe5";
      };
    }
    {
      name = "_parcel_logger___logger_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_logger___logger_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/logger/-/logger-2.4.1.tgz";
        sha1 = "8f87097009d6847409da69ecbc248a136b2f36c2";
      };
    }
    {
      name = "_parcel_markdown_ansi___markdown_ansi_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_markdown_ansi___markdown_ansi_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/markdown-ansi/-/markdown-ansi-2.4.1.tgz";
        sha1 = "65f798234e5767d92c5f411de5aae11e611cd9b6";
      };
    }
    {
      name = "_parcel_namer_default___namer_default_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_namer_default___namer_default_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/namer-default/-/namer-default-2.4.1.tgz";
        sha1 = "63442b2bf06ec555f825924435f450c9768bcc5a";
      };
    }
    {
      name = "_parcel_node_resolver_core___node_resolver_core_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_node_resolver_core___node_resolver_core_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/node-resolver-core/-/node-resolver-core-2.4.1.tgz";
        sha1 = "640fd087f610f030db7411bb2f61ae0e896d7cd1";
      };
    }
    {
      name = "_parcel_optimizer_css___optimizer_css_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_optimizer_css___optimizer_css_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/optimizer-css/-/optimizer-css-2.4.1.tgz";
        sha1 = "67a6db736f3a2dce506cfefe40c12d25f23d530a";
      };
    }
    {
      name = "_parcel_optimizer_htmlnano___optimizer_htmlnano_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_optimizer_htmlnano___optimizer_htmlnano_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/optimizer-htmlnano/-/optimizer-htmlnano-2.4.1.tgz";
        sha1 = "18995b850fb1835a60c84378abff01b337f50cc7";
      };
    }
    {
      name = "_parcel_optimizer_image___optimizer_image_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_optimizer_image___optimizer_image_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/optimizer-image/-/optimizer-image-2.4.1.tgz";
        sha1 = "f3fd069290268c84e9a12bdda7dc5ded781c874e";
      };
    }
    {
      name = "_parcel_optimizer_svgo___optimizer_svgo_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_optimizer_svgo___optimizer_svgo_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/optimizer-svgo/-/optimizer-svgo-2.4.1.tgz";
        sha1 = "ff925aa40ca84a5dd816716662d22fb217b52288";
      };
    }
    {
      name = "_parcel_optimizer_terser___optimizer_terser_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_optimizer_terser___optimizer_terser_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/optimizer-terser/-/optimizer-terser-2.4.1.tgz";
        sha1 = "999ae4551448540494f79861d4f68eb0cd0bfa48";
      };
    }
    {
      name = "_parcel_package_manager___package_manager_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_package_manager___package_manager_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/package-manager/-/package-manager-2.4.1.tgz";
        sha1 = "fcd05b0d1999bef52496599043e0d5432abf57da";
      };
    }
    {
      name = "_parcel_packager_css___packager_css_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_packager_css___packager_css_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/packager-css/-/packager-css-2.4.1.tgz";
        sha1 = "644d1b50426f08f08dd13beea6cd5b5a75d2d11b";
      };
    }
    {
      name = "_parcel_packager_html___packager_html_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_packager_html___packager_html_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/packager-html/-/packager-html-2.4.1.tgz";
        sha1 = "6aa04c2650e4586fae0a5aa09913ee165d968cb9";
      };
    }
    {
      name = "_parcel_packager_js___packager_js_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_packager_js___packager_js_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/packager-js/-/packager-js-2.4.1.tgz";
        sha1 = "f544f9e48718a1187be7856a5e638dc231e1867e";
      };
    }
    {
      name = "_parcel_packager_raw___packager_raw_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_packager_raw___packager_raw_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/packager-raw/-/packager-raw-2.4.1.tgz";
        sha1 = "2566bd6187cf4e2393e5aad2b567d803248fdacb";
      };
    }
    {
      name = "_parcel_packager_svg___packager_svg_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_packager_svg___packager_svg_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/packager-svg/-/packager-svg-2.4.1.tgz";
        sha1 = "218c2b1e2efee648b4113ca72ed314a83ad38522";
      };
    }
    {
      name = "_parcel_plugin___plugin_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_plugin___plugin_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/plugin/-/plugin-2.4.1.tgz";
        sha1 = "15294d796be2703b16fa4e617967cfaa8e5631d4";
      };
    }
    {
      name = "_parcel_reporter_cli___reporter_cli_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_reporter_cli___reporter_cli_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/reporter-cli/-/reporter-cli-2.4.1.tgz";
        sha1 = "011a84e4da9fdc5f65c7c44c31f7b24c8841ea8a";
      };
    }
    {
      name = "_parcel_reporter_dev_server___reporter_dev_server_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_reporter_dev_server___reporter_dev_server_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/reporter-dev-server/-/reporter-dev-server-2.4.1.tgz";
        sha1 = "dc29b399f0402ad6327fa1697ddc8bee74e7ff7d";
      };
    }
    {
      name = "_parcel_resolver_default___resolver_default_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_resolver_default___resolver_default_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/resolver-default/-/resolver-default-2.4.1.tgz";
        sha1 = "0ac851a42c9fb7521936339341f69730e6052495";
      };
    }
    {
      name = "_parcel_runtime_browser_hmr___runtime_browser_hmr_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_runtime_browser_hmr___runtime_browser_hmr_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/runtime-browser-hmr/-/runtime-browser-hmr-2.4.1.tgz";
        sha1 = "dcc0d5b41e5662aa694dc5ad937c00d088c80dca";
      };
    }
    {
      name = "_parcel_runtime_js___runtime_js_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_runtime_js___runtime_js_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/runtime-js/-/runtime-js-2.4.1.tgz";
        sha1 = "7322a434a49ce78a14dccfb945dfc24f009397df";
      };
    }
    {
      name = "_parcel_runtime_react_refresh___runtime_react_refresh_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_runtime_react_refresh___runtime_react_refresh_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/runtime-react-refresh/-/runtime-react-refresh-2.4.1.tgz";
        sha1 = "86c9e2bbf4ce7a4bfed493da07716f8c3a24948d";
      };
    }
    {
      name = "_parcel_runtime_service_worker___runtime_service_worker_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_runtime_service_worker___runtime_service_worker_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/runtime-service-worker/-/runtime-service-worker-2.4.1.tgz";
        sha1 = "928fb063273766ea52d8839758c212bbc657f1cb";
      };
    }
    {
      name = "_parcel_source_map___source_map_2.0.2.tgz";
      path = fetchurl {
        name = "_parcel_source_map___source_map_2.0.2.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/source-map/-/source-map-2.0.2.tgz";
        sha1 = "9aa0b00518cee31d5634de6e9c924a5539b142c1";
      };
    }
    {
      name = "_parcel_transformer_babel___transformer_babel_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_transformer_babel___transformer_babel_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/transformer-babel/-/transformer-babel-2.4.1.tgz";
        sha1 = "55e1a9587dd90adb4b3a16e600f625972a3a7a0f";
      };
    }
    {
      name = "_parcel_transformer_css___transformer_css_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_transformer_css___transformer_css_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/transformer-css/-/transformer-css-2.4.1.tgz";
        sha1 = "974cdf17ddf6a0a0a87c9f709d1c631b344e1820";
      };
    }
    {
      name = "_parcel_transformer_html___transformer_html_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_transformer_html___transformer_html_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/transformer-html/-/transformer-html-2.4.1.tgz";
        sha1 = "f24ba5bc1d34c369e1d361e20e32fd194fc4aae0";
      };
    }
    {
      name = "_parcel_transformer_image___transformer_image_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_transformer_image___transformer_image_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/transformer-image/-/transformer-image-2.4.1.tgz";
        sha1 = "5b3f97d8d41b08b29c47a0ca7cef6600520098ea";
      };
    }
    {
      name = "_parcel_transformer_js___transformer_js_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_transformer_js___transformer_js_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/transformer-js/-/transformer-js-2.4.1.tgz";
        sha1 = "824fc0cf86225a18eb3ac330a5096795ffb65374";
      };
    }
    {
      name = "_parcel_transformer_json___transformer_json_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_transformer_json___transformer_json_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/transformer-json/-/transformer-json-2.4.1.tgz";
        sha1 = "0585e539db5a81899a0409cfee63f509b81d6962";
      };
    }
    {
      name = "_parcel_transformer_postcss___transformer_postcss_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_transformer_postcss___transformer_postcss_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/transformer-postcss/-/transformer-postcss-2.4.1.tgz";
        sha1 = "5082c9733d4b8433c69466b1b532e23deaa36529";
      };
    }
    {
      name = "_parcel_transformer_posthtml___transformer_posthtml_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_transformer_posthtml___transformer_posthtml_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/transformer-posthtml/-/transformer-posthtml-2.4.1.tgz";
        sha1 = "c5187fd92f38de1e8d05d17a6c849818eeaa2d7c";
      };
    }
    {
      name = "_parcel_transformer_raw___transformer_raw_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_transformer_raw___transformer_raw_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/transformer-raw/-/transformer-raw-2.4.1.tgz";
        sha1 = "5e1842fbd661b6058294a7ba984a34b6896c3e65";
      };
    }
    {
      name = "_parcel_transformer_react_refresh_wrap___transformer_react_refresh_wrap_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_transformer_react_refresh_wrap___transformer_react_refresh_wrap_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/transformer-react-refresh-wrap/-/transformer-react-refresh-wrap-2.4.1.tgz";
        sha1 = "14f9194f30e417b46fc325f78ee4035254670f64";
      };
    }
    {
      name = "_parcel_transformer_svg___transformer_svg_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_transformer_svg___transformer_svg_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/transformer-svg/-/transformer-svg-2.4.1.tgz";
        sha1 = "30381670312f4a512e714b47abd4c501e1d2401f";
      };
    }
    {
      name = "_parcel_types___types_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_types___types_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/types/-/types-2.4.1.tgz";
        sha1 = "4cd7b99db403ec36a1fe9f31a6320b2f6148f580";
      };
    }
    {
      name = "_parcel_utils___utils_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_utils___utils_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/utils/-/utils-2.4.1.tgz";
        sha1 = "1d8e30fc0fb61a52c3445235f0ed2e0130a29797";
      };
    }
    {
      name = "_parcel_watcher___watcher_2.0.5.tgz";
      path = fetchurl {
        name = "_parcel_watcher___watcher_2.0.5.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/watcher/-/watcher-2.0.5.tgz";
        sha1 = "f913a54e1601b0aac972803829b0eece48de215b";
      };
    }
    {
      name = "_parcel_workers___workers_2.4.1.tgz";
      path = fetchurl {
        name = "_parcel_workers___workers_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/@parcel/workers/-/workers-2.4.1.tgz";
        sha1 = "27bc3ac703625bc1694873fee07fdbeaf555d987";
      };
    }
    {
      name = "_swc_helpers___helpers_0.3.8.tgz";
      path = fetchurl {
        name = "_swc_helpers___helpers_0.3.8.tgz";
        url  = "https://registry.yarnpkg.com/@swc/helpers/-/helpers-0.3.8.tgz";
        sha1 = "5b9ecf4ee480ca00f1ffbc2d1a5d4eed0d1afe81";
      };
    }
    {
      name = "_trysound_sax___sax_0.2.0.tgz";
      path = fetchurl {
        name = "_trysound_sax___sax_0.2.0.tgz";
        url  = "https://registry.yarnpkg.com/@trysound/sax/-/sax-0.2.0.tgz";
        sha1 = "cccaab758af56761eb7bf37af6f03f326dd798ad";
      };
    }
    {
      name = "_types_parse_json___parse_json_4.0.0.tgz";
      path = fetchurl {
        name = "_types_parse_json___parse_json_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/@types/parse-json/-/parse-json-4.0.0.tgz";
        sha1 = "2f8bb441434d163b35fb8ffdccd7138927ffb8c0";
      };
    }
    {
      name = "abortcontroller_polyfill___abortcontroller_polyfill_1.7.3.tgz";
      path = fetchurl {
        name = "abortcontroller_polyfill___abortcontroller_polyfill_1.7.3.tgz";
        url  = "https://registry.yarnpkg.com/abortcontroller-polyfill/-/abortcontroller-polyfill-1.7.3.tgz";
        sha1 = "1b5b487bd6436b5b764fd52a612509702c3144b5";
      };
    }
    {
      name = "acorn___acorn_8.7.0.tgz";
      path = fetchurl {
        name = "acorn___acorn_8.7.0.tgz";
        url  = "https://registry.yarnpkg.com/acorn/-/acorn-8.7.0.tgz";
        sha1 = "90951fde0f8f09df93549481e5fc141445b791cf";
      };
    }
    {
      name = "ansi_styles___ansi_styles_3.2.1.tgz";
      path = fetchurl {
        name = "ansi_styles___ansi_styles_3.2.1.tgz";
        url  = "https://registry.yarnpkg.com/ansi-styles/-/ansi-styles-3.2.1.tgz";
        sha1 = "41fbb20243e50b12be0f04b8dedbf07520ce841d";
      };
    }
    {
      name = "ansi_styles___ansi_styles_4.3.0.tgz";
      path = fetchurl {
        name = "ansi_styles___ansi_styles_4.3.0.tgz";
        url  = "https://registry.yarnpkg.com/ansi-styles/-/ansi-styles-4.3.0.tgz";
        sha1 = "edd803628ae71c04c85ae7a0906edad34b648937";
      };
    }
    {
      name = "base_x___base_x_3.0.9.tgz";
      path = fetchurl {
        name = "base_x___base_x_3.0.9.tgz";
        url  = "https://registry.yarnpkg.com/base-x/-/base-x-3.0.9.tgz";
        sha1 = "6349aaabb58526332de9f60995e548a53fe21320";
      };
    }
    {
      name = "boolbase___boolbase_1.0.0.tgz";
      path = fetchurl {
        name = "boolbase___boolbase_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/boolbase/-/boolbase-1.0.0.tgz";
        sha1 = "68dff5fbe60c51eb37725ea9e3ed310dcc1e776e";
      };
    }
    {
      name = "browserslist___browserslist_4.20.2.tgz";
      path = fetchurl {
        name = "browserslist___browserslist_4.20.2.tgz";
        url  = "https://registry.yarnpkg.com/browserslist/-/browserslist-4.20.2.tgz";
        sha1 = "567b41508757ecd904dab4d1c646c612cd3d4f88";
      };
    }
    {
      name = "buffer_from___buffer_from_1.1.1.tgz";
      path = fetchurl {
        name = "buffer_from___buffer_from_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/buffer-from/-/buffer-from-1.1.1.tgz";
        sha1 = "32713bc028f75c02fdb710d7c7bcec1f2c6070ef";
      };
    }
    {
      name = "callsites___callsites_3.1.0.tgz";
      path = fetchurl {
        name = "callsites___callsites_3.1.0.tgz";
        url  = "https://registry.yarnpkg.com/callsites/-/callsites-3.1.0.tgz";
        sha1 = "b3630abd8943432f54b3f0519238e33cd7df2f73";
      };
    }
    {
      name = "caniuse_lite___caniuse_lite_1.0.30001324.tgz";
      path = fetchurl {
        name = "caniuse_lite___caniuse_lite_1.0.30001324.tgz";
        url  = "https://registry.yarnpkg.com/caniuse-lite/-/caniuse-lite-1.0.30001324.tgz";
        sha1 = "e17c3a8b34822b02d5d15639d570057550074884";
      };
    }
    {
      name = "chalk___chalk_2.4.2.tgz";
      path = fetchurl {
        name = "chalk___chalk_2.4.2.tgz";
        url  = "https://registry.yarnpkg.com/chalk/-/chalk-2.4.2.tgz";
        sha1 = "cd42541677a54333cf541a49108c1432b44c9424";
      };
    }
    {
      name = "chalk___chalk_4.1.2.tgz";
      path = fetchurl {
        name = "chalk___chalk_4.1.2.tgz";
        url  = "https://registry.yarnpkg.com/chalk/-/chalk-4.1.2.tgz";
        sha1 = "aac4e2b7734a740867aeb16bf02aad556a1e7a01";
      };
    }
    {
      name = "chrome_trace_event___chrome_trace_event_1.0.3.tgz";
      path = fetchurl {
        name = "chrome_trace_event___chrome_trace_event_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/chrome-trace-event/-/chrome-trace-event-1.0.3.tgz";
        sha1 = "1015eced4741e15d06664a957dbbf50d041e26ac";
      };
    }
    {
      name = "clone___clone_2.1.2.tgz";
      path = fetchurl {
        name = "clone___clone_2.1.2.tgz";
        url  = "https://registry.yarnpkg.com/clone/-/clone-2.1.2.tgz";
        sha1 = "1b7f4b9f591f1e8f83670401600345a02887435f";
      };
    }
    {
      name = "color_convert___color_convert_1.9.3.tgz";
      path = fetchurl {
        name = "color_convert___color_convert_1.9.3.tgz";
        url  = "https://registry.yarnpkg.com/color-convert/-/color-convert-1.9.3.tgz";
        sha1 = "bb71850690e1f136567de629d2d5471deda4c1e8";
      };
    }
    {
      name = "color_convert___color_convert_2.0.1.tgz";
      path = fetchurl {
        name = "color_convert___color_convert_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/color-convert/-/color-convert-2.0.1.tgz";
        sha1 = "72d3a68d598c9bdb3af2ad1e84f21d896abd4de3";
      };
    }
    {
      name = "color_name___color_name_1.1.3.tgz";
      path = fetchurl {
        name = "color_name___color_name_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/color-name/-/color-name-1.1.3.tgz";
        sha1 = "a7d0558bd89c42f795dd42328f740831ca53bc25";
      };
    }
    {
      name = "color_name___color_name_1.1.4.tgz";
      path = fetchurl {
        name = "color_name___color_name_1.1.4.tgz";
        url  = "https://registry.yarnpkg.com/color-name/-/color-name-1.1.4.tgz";
        sha1 = "c2a09a87acbde69543de6f63fa3995c826c536a2";
      };
    }
    {
      name = "commander___commander_2.20.3.tgz";
      path = fetchurl {
        name = "commander___commander_2.20.3.tgz";
        url  = "https://registry.yarnpkg.com/commander/-/commander-2.20.3.tgz";
        sha1 = "fd485e84c03eb4881c20722ba48035e8531aeb33";
      };
    }
    {
      name = "commander___commander_7.2.0.tgz";
      path = fetchurl {
        name = "commander___commander_7.2.0.tgz";
        url  = "https://registry.yarnpkg.com/commander/-/commander-7.2.0.tgz";
        sha1 = "a36cb57d0b501ce108e4d20559a150a391d97ab7";
      };
    }
    {
      name = "cosmiconfig___cosmiconfig_7.0.1.tgz";
      path = fetchurl {
        name = "cosmiconfig___cosmiconfig_7.0.1.tgz";
        url  = "https://registry.yarnpkg.com/cosmiconfig/-/cosmiconfig-7.0.1.tgz";
        sha1 = "714d756522cace867867ccb4474c5d01bbae5d6d";
      };
    }
    {
      name = "css_select___css_select_4.3.0.tgz";
      path = fetchurl {
        name = "css_select___css_select_4.3.0.tgz";
        url  = "https://registry.yarnpkg.com/css-select/-/css-select-4.3.0.tgz";
        sha1 = "db7129b2846662fd8628cfc496abb2b59e41529b";
      };
    }
    {
      name = "css_tree___css_tree_1.1.3.tgz";
      path = fetchurl {
        name = "css_tree___css_tree_1.1.3.tgz";
        url  = "https://registry.yarnpkg.com/css-tree/-/css-tree-1.1.3.tgz";
        sha1 = "eb4870fb6fd7707327ec95c2ff2ab09b5e8db91d";
      };
    }
    {
      name = "css_what___css_what_6.1.0.tgz";
      path = fetchurl {
        name = "css_what___css_what_6.1.0.tgz";
        url  = "https://registry.yarnpkg.com/css-what/-/css-what-6.1.0.tgz";
        sha1 = "fb5effcf76f1ddea2c81bdfaa4de44e79bac70f4";
      };
    }
    {
      name = "csso___csso_4.2.0.tgz";
      path = fetchurl {
        name = "csso___csso_4.2.0.tgz";
        url  = "https://registry.yarnpkg.com/csso/-/csso-4.2.0.tgz";
        sha1 = "ea3a561346e8dc9f546d6febedd50187cf389529";
      };
    }
    {
      name = "detect_libc___detect_libc_1.0.3.tgz";
      path = fetchurl {
        name = "detect_libc___detect_libc_1.0.3.tgz";
        url  = "https://registry.yarnpkg.com/detect-libc/-/detect-libc-1.0.3.tgz";
        sha1 = "fa137c4bd698edf55cd5cd02ac559f91a4c4ba9b";
      };
    }
    {
      name = "dom_serializer___dom_serializer_1.3.2.tgz";
      path = fetchurl {
        name = "dom_serializer___dom_serializer_1.3.2.tgz";
        url  = "https://registry.yarnpkg.com/dom-serializer/-/dom-serializer-1.3.2.tgz";
        sha1 = "6206437d32ceefaec7161803230c7a20bc1b4d91";
      };
    }
    {
      name = "domelementtype___domelementtype_2.2.0.tgz";
      path = fetchurl {
        name = "domelementtype___domelementtype_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/domelementtype/-/domelementtype-2.2.0.tgz";
        sha1 = "9a0b6c2782ed6a1c7323d42267183df9bd8b1d57";
      };
    }
    {
      name = "domhandler___domhandler_4.2.0.tgz";
      path = fetchurl {
        name = "domhandler___domhandler_4.2.0.tgz";
        url  = "https://registry.yarnpkg.com/domhandler/-/domhandler-4.2.0.tgz";
        sha1 = "f9768a5f034be60a89a27c2e4d0f74eba0d8b059";
      };
    }
    {
      name = "domhandler___domhandler_4.3.1.tgz";
      path = fetchurl {
        name = "domhandler___domhandler_4.3.1.tgz";
        url  = "https://registry.yarnpkg.com/domhandler/-/domhandler-4.3.1.tgz";
        sha1 = "8d792033416f59d68bc03a5aa7b018c1ca89279c";
      };
    }
    {
      name = "domutils___domutils_2.8.0.tgz";
      path = fetchurl {
        name = "domutils___domutils_2.8.0.tgz";
        url  = "https://registry.yarnpkg.com/domutils/-/domutils-2.8.0.tgz";
        sha1 = "4437def5db6e2d1f5d6ee859bd95ca7d02048135";
      };
    }
    {
      name = "dotenv_expand___dotenv_expand_5.1.0.tgz";
      path = fetchurl {
        name = "dotenv_expand___dotenv_expand_5.1.0.tgz";
        url  = "https://registry.yarnpkg.com/dotenv-expand/-/dotenv-expand-5.1.0.tgz";
        sha1 = "3fbaf020bfd794884072ea26b1e9791d45a629f0";
      };
    }
    {
      name = "dotenv___dotenv_7.0.0.tgz";
      path = fetchurl {
        name = "dotenv___dotenv_7.0.0.tgz";
        url  = "https://registry.yarnpkg.com/dotenv/-/dotenv-7.0.0.tgz";
        sha1 = "a2be3cd52736673206e8a85fb5210eea29628e7c";
      };
    }
    {
      name = "electron_to_chromium___electron_to_chromium_1.4.103.tgz";
      path = fetchurl {
        name = "electron_to_chromium___electron_to_chromium_1.4.103.tgz";
        url  = "https://registry.yarnpkg.com/electron-to-chromium/-/electron-to-chromium-1.4.103.tgz";
        sha1 = "abfe376a4d70fa1e1b4b353b95df5d6dfd05da3a";
      };
    }
    {
      name = "entities___entities_2.2.0.tgz";
      path = fetchurl {
        name = "entities___entities_2.2.0.tgz";
        url  = "https://registry.yarnpkg.com/entities/-/entities-2.2.0.tgz";
        sha1 = "098dc90ebb83d8dffa089d55256b351d34c4da55";
      };
    }
    {
      name = "entities___entities_3.0.1.tgz";
      path = fetchurl {
        name = "entities___entities_3.0.1.tgz";
        url  = "https://registry.yarnpkg.com/entities/-/entities-3.0.1.tgz";
        sha1 = "2b887ca62585e96db3903482d336c1006c3001d4";
      };
    }
    {
      name = "error_ex___error_ex_1.3.2.tgz";
      path = fetchurl {
        name = "error_ex___error_ex_1.3.2.tgz";
        url  = "https://registry.yarnpkg.com/error-ex/-/error-ex-1.3.2.tgz";
        sha1 = "b4ac40648107fdcdcfae242f428bea8a14d4f1bf";
      };
    }
    {
      name = "escalade___escalade_3.1.1.tgz";
      path = fetchurl {
        name = "escalade___escalade_3.1.1.tgz";
        url  = "https://registry.yarnpkg.com/escalade/-/escalade-3.1.1.tgz";
        sha1 = "d8cfdc7000965c5a0174b4a82eaa5c0552742e40";
      };
    }
    {
      name = "escape_string_regexp___escape_string_regexp_1.0.5.tgz";
      path = fetchurl {
        name = "escape_string_regexp___escape_string_regexp_1.0.5.tgz";
        url  = "https://registry.yarnpkg.com/escape-string-regexp/-/escape-string-regexp-1.0.5.tgz";
        sha1 = "1b61c0562190a8dff6ae3bb2cf0200ca130b86d4";
      };
    }
    {
      name = "get_port___get_port_4.2.0.tgz";
      path = fetchurl {
        name = "get_port___get_port_4.2.0.tgz";
        url  = "https://registry.yarnpkg.com/get-port/-/get-port-4.2.0.tgz";
        sha1 = "e37368b1e863b7629c43c5a323625f95cf24b119";
      };
    }
    {
      name = "globals___globals_13.13.0.tgz";
      path = fetchurl {
        name = "globals___globals_13.13.0.tgz";
        url  = "https://registry.yarnpkg.com/globals/-/globals-13.13.0.tgz";
        sha1 = "ac32261060d8070e2719dd6998406e27d2b5727b";
      };
    }
    {
      name = "has_flag___has_flag_3.0.0.tgz";
      path = fetchurl {
        name = "has_flag___has_flag_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/has-flag/-/has-flag-3.0.0.tgz";
        sha1 = "b5d454dc2199ae225699f3467e5a07f3b955bafd";
      };
    }
    {
      name = "has_flag___has_flag_4.0.0.tgz";
      path = fetchurl {
        name = "has_flag___has_flag_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/has-flag/-/has-flag-4.0.0.tgz";
        sha1 = "944771fd9c81c81265c4d6941860da06bb59479b";
      };
    }
    {
      name = "htmlnano___htmlnano_2.0.0.tgz";
      path = fetchurl {
        name = "htmlnano___htmlnano_2.0.0.tgz";
        url  = "https://registry.yarnpkg.com/htmlnano/-/htmlnano-2.0.0.tgz";
        sha1 = "07376faa064f7e1e832dfd91e1a9f606b0bc9b78";
      };
    }
    {
      name = "htmlparser2___htmlparser2_7.2.0.tgz";
      path = fetchurl {
        name = "htmlparser2___htmlparser2_7.2.0.tgz";
        url  = "https://registry.yarnpkg.com/htmlparser2/-/htmlparser2-7.2.0.tgz";
        sha1 = "8817cdea38bbc324392a90b1990908e81a65f5a5";
      };
    }
    {
      name = "import_fresh___import_fresh_3.3.0.tgz";
      path = fetchurl {
        name = "import_fresh___import_fresh_3.3.0.tgz";
        url  = "https://registry.yarnpkg.com/import-fresh/-/import-fresh-3.3.0.tgz";
        sha1 = "37162c25fcb9ebaa2e6e53d5b4d88ce17d9e0c2b";
      };
    }
    {
      name = "is_arrayish___is_arrayish_0.2.1.tgz";
      path = fetchurl {
        name = "is_arrayish___is_arrayish_0.2.1.tgz";
        url  = "https://registry.yarnpkg.com/is-arrayish/-/is-arrayish-0.2.1.tgz";
        sha1 = "77c99840527aa8ecb1a8ba697b80645a7a926a9d";
      };
    }
    {
      name = "is_json___is_json_2.0.1.tgz";
      path = fetchurl {
        name = "is_json___is_json_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/is-json/-/is-json-2.0.1.tgz";
        sha1 = "6be166d144828a131d686891b983df62c39491ff";
      };
    }
    {
      name = "js_tokens___js_tokens_4.0.0.tgz";
      path = fetchurl {
        name = "js_tokens___js_tokens_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/js-tokens/-/js-tokens-4.0.0.tgz";
        sha1 = "19203fb59991df98e3a287050d4647cdeaf32499";
      };
    }
    {
      name = "json_parse_even_better_errors___json_parse_even_better_errors_2.3.1.tgz";
      path = fetchurl {
        name = "json_parse_even_better_errors___json_parse_even_better_errors_2.3.1.tgz";
        url  = "https://registry.yarnpkg.com/json-parse-even-better-errors/-/json-parse-even-better-errors-2.3.1.tgz";
        sha1 = "7c47805a94319928e05777405dc12e1f7a4ee02d";
      };
    }
    {
      name = "json_source_map___json_source_map_0.6.1.tgz";
      path = fetchurl {
        name = "json_source_map___json_source_map_0.6.1.tgz";
        url  = "https://registry.yarnpkg.com/json-source-map/-/json-source-map-0.6.1.tgz";
        sha1 = "e0b1f6f4ce13a9ad57e2ae165a24d06e62c79a0f";
      };
    }
    {
      name = "json5___json5_2.2.1.tgz";
      path = fetchurl {
        name = "json5___json5_2.2.1.tgz";
        url  = "https://registry.yarnpkg.com/json5/-/json5-2.2.1.tgz";
        sha1 = "655d50ed1e6f95ad1a3caababd2b0efda10b395c";
      };
    }
    {
      name = "lines_and_columns___lines_and_columns_1.2.4.tgz";
      path = fetchurl {
        name = "lines_and_columns___lines_and_columns_1.2.4.tgz";
        url  = "https://registry.yarnpkg.com/lines-and-columns/-/lines-and-columns-1.2.4.tgz";
        sha1 = "eca284f75d2965079309dc0ad9255abb2ebc1632";
      };
    }
    {
      name = "lit_html___lit_html_1.4.1.tgz";
      path = fetchurl {
        name = "lit_html___lit_html_1.4.1.tgz";
        url  = "https://registry.yarnpkg.com/lit-html/-/lit-html-1.4.1.tgz";
        sha1 = "0c6f3ee4ad4eb610a49831787f0478ad8e9ae5e0";
      };
    }
    {
      name = "lmdb___lmdb_2.2.4.tgz";
      path = fetchurl {
        name = "lmdb___lmdb_2.2.4.tgz";
        url  = "https://registry.yarnpkg.com/lmdb/-/lmdb-2.2.4.tgz";
        sha1 = "6494d5a1d1db152e0be759edcfa06893e4cbdb53";
      };
    }
    {
      name = "mdn_data___mdn_data_2.0.14.tgz";
      path = fetchurl {
        name = "mdn_data___mdn_data_2.0.14.tgz";
        url  = "https://registry.yarnpkg.com/mdn-data/-/mdn-data-2.0.14.tgz";
        sha1 = "7113fc4281917d63ce29b43446f701e68c25ba50";
      };
    }
    {
      name = "msgpackr_extract___msgpackr_extract_1.0.16.tgz";
      path = fetchurl {
        name = "msgpackr_extract___msgpackr_extract_1.0.16.tgz";
        url  = "https://registry.yarnpkg.com/msgpackr-extract/-/msgpackr-extract-1.0.16.tgz";
        sha1 = "701c4f6e6f25c100ae84557092274e8fffeefe45";
      };
    }
    {
      name = "msgpackr___msgpackr_1.5.5.tgz";
      path = fetchurl {
        name = "msgpackr___msgpackr_1.5.5.tgz";
        url  = "https://registry.yarnpkg.com/msgpackr/-/msgpackr-1.5.5.tgz";
        sha1 = "c0562abc2951d7e29f75d77a8656b01f103a042c";
      };
    }
    {
      name = "nan___nan_2.15.0.tgz";
      path = fetchurl {
        name = "nan___nan_2.15.0.tgz";
        url  = "https://registry.yarnpkg.com/nan/-/nan-2.15.0.tgz";
        sha1 = "3f34a473ff18e15c1b5626b62903b5ad6e665fee";
      };
    }
    {
      name = "node_addon_api___node_addon_api_3.2.1.tgz";
      path = fetchurl {
        name = "node_addon_api___node_addon_api_3.2.1.tgz";
        url  = "https://registry.yarnpkg.com/node-addon-api/-/node-addon-api-3.2.1.tgz";
        sha1 = "81325e0a2117789c0128dab65e7e38f07ceba161";
      };
    }
    {
      name = "node_gyp_build___node_gyp_build_4.4.0.tgz";
      path = fetchurl {
        name = "node_gyp_build___node_gyp_build_4.4.0.tgz";
        url  = "https://registry.yarnpkg.com/node-gyp-build/-/node-gyp-build-4.4.0.tgz";
        sha1 = "42e99687ce87ddeaf3a10b99dc06abc11021f3f4";
      };
    }
    {
      name = "node_releases___node_releases_2.0.2.tgz";
      path = fetchurl {
        name = "node_releases___node_releases_2.0.2.tgz";
        url  = "https://registry.yarnpkg.com/node-releases/-/node-releases-2.0.2.tgz";
        sha1 = "7139fe71e2f4f11b47d4d2986aaf8c48699e0c01";
      };
    }
    {
      name = "nth_check___nth_check_2.0.1.tgz";
      path = fetchurl {
        name = "nth_check___nth_check_2.0.1.tgz";
        url  = "https://registry.yarnpkg.com/nth-check/-/nth-check-2.0.1.tgz";
        sha1 = "2efe162f5c3da06a28959fbd3db75dbeea9f0fc2";
      };
    }
    {
      name = "nullthrows___nullthrows_1.1.1.tgz";
      path = fetchurl {
        name = "nullthrows___nullthrows_1.1.1.tgz";
        url  = "https://registry.yarnpkg.com/nullthrows/-/nullthrows-1.1.1.tgz";
        sha1 = "7818258843856ae971eae4208ad7d7eb19a431b1";
      };
    }
    {
      name = "opensans_npm_webfont___opensans_npm_webfont_1.0.0.tgz";
      path = fetchurl {
        name = "opensans_npm_webfont___opensans_npm_webfont_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/opensans-npm-webfont/-/opensans-npm-webfont-1.0.0.tgz";
        sha1 = "910c8e525887b47eb8a6795846138a0cbac15a47";
      };
    }
    {
      name = "ordered_binary___ordered_binary_1.2.4.tgz";
      path = fetchurl {
        name = "ordered_binary___ordered_binary_1.2.4.tgz";
        url  = "https://registry.yarnpkg.com/ordered-binary/-/ordered-binary-1.2.4.tgz";
        sha1 = "51d3a03af078a0bdba6c7bc8f4fedd1f5d45d83e";
      };
    }
    {
      name = "parcel___parcel_2.4.1.tgz";
      path = fetchurl {
        name = "parcel___parcel_2.4.1.tgz";
        url  = "https://registry.yarnpkg.com/parcel/-/parcel-2.4.1.tgz";
        sha1 = "e369d0c1a3f383df244eb546d0613d1df51f6b35";
      };
    }
    {
      name = "parent_module___parent_module_1.0.1.tgz";
      path = fetchurl {
        name = "parent_module___parent_module_1.0.1.tgz";
        url  = "https://registry.yarnpkg.com/parent-module/-/parent-module-1.0.1.tgz";
        sha1 = "691d2709e78c79fae3a156622452d00762caaaa2";
      };
    }
    {
      name = "parse_json___parse_json_5.2.0.tgz";
      path = fetchurl {
        name = "parse_json___parse_json_5.2.0.tgz";
        url  = "https://registry.yarnpkg.com/parse-json/-/parse-json-5.2.0.tgz";
        sha1 = "c76fc66dee54231c962b22bcc8a72cf2f99753cd";
      };
    }
    {
      name = "path_type___path_type_4.0.0.tgz";
      path = fetchurl {
        name = "path_type___path_type_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/path-type/-/path-type-4.0.0.tgz";
        sha1 = "84ed01c0a7ba380afe09d90a8c180dcd9d03043b";
      };
    }
    {
      name = "picocolors___picocolors_1.0.0.tgz";
      path = fetchurl {
        name = "picocolors___picocolors_1.0.0.tgz";
        url  = "https://registry.yarnpkg.com/picocolors/-/picocolors-1.0.0.tgz";
        sha1 = "cb5bdc74ff3f51892236eaf79d68bc44564ab81c";
      };
    }
    {
      name = "postcss_value_parser___postcss_value_parser_4.2.0.tgz";
      path = fetchurl {
        name = "postcss_value_parser___postcss_value_parser_4.2.0.tgz";
        url  = "https://registry.yarnpkg.com/postcss-value-parser/-/postcss-value-parser-4.2.0.tgz";
        sha1 = "723c09920836ba6d3e5af019f92bc0971c02e514";
      };
    }
    {
      name = "posthtml_parser___posthtml_parser_0.10.2.tgz";
      path = fetchurl {
        name = "posthtml_parser___posthtml_parser_0.10.2.tgz";
        url  = "https://registry.yarnpkg.com/posthtml-parser/-/posthtml-parser-0.10.2.tgz";
        sha1 = "df364d7b179f2a6bf0466b56be7b98fd4e97c573";
      };
    }
    {
      name = "posthtml_parser___posthtml_parser_0.11.0.tgz";
      path = fetchurl {
        name = "posthtml_parser___posthtml_parser_0.11.0.tgz";
        url  = "https://registry.yarnpkg.com/posthtml-parser/-/posthtml-parser-0.11.0.tgz";
        sha1 = "25d1c7bf811ea83559bc4c21c189a29747a24b7a";
      };
    }
    {
      name = "posthtml_render___posthtml_render_3.0.0.tgz";
      path = fetchurl {
        name = "posthtml_render___posthtml_render_3.0.0.tgz";
        url  = "https://registry.yarnpkg.com/posthtml-render/-/posthtml-render-3.0.0.tgz";
        sha1 = "97be44931496f495b4f07b99e903cc70ad6a3205";
      };
    }
    {
      name = "posthtml___posthtml_0.16.6.tgz";
      path = fetchurl {
        name = "posthtml___posthtml_0.16.6.tgz";
        url  = "https://registry.yarnpkg.com/posthtml/-/posthtml-0.16.6.tgz";
        sha1 = "e2fc407f67a64d2fa3567afe770409ffdadafe59";
      };
    }
    {
      name = "react_refresh___react_refresh_0.9.0.tgz";
      path = fetchurl {
        name = "react_refresh___react_refresh_0.9.0.tgz";
        url  = "https://registry.yarnpkg.com/react-refresh/-/react-refresh-0.9.0.tgz";
        sha1 = "71863337adc3e5c2f8a6bfddd12ae3bfe32aafbf";
      };
    }
    {
      name = "regenerator_runtime___regenerator_runtime_0.13.9.tgz";
      path = fetchurl {
        name = "regenerator_runtime___regenerator_runtime_0.13.9.tgz";
        url  = "https://registry.yarnpkg.com/regenerator-runtime/-/regenerator-runtime-0.13.9.tgz";
        sha1 = "8925742a98ffd90814988d7566ad30ca3b263b52";
      };
    }
    {
      name = "resolve_from___resolve_from_4.0.0.tgz";
      path = fetchurl {
        name = "resolve_from___resolve_from_4.0.0.tgz";
        url  = "https://registry.yarnpkg.com/resolve-from/-/resolve-from-4.0.0.tgz";
        sha1 = "4abcd852ad32dd7baabfe9b40e00a36db5f392e6";
      };
    }
    {
      name = "safe_buffer___safe_buffer_5.2.1.tgz";
      path = fetchurl {
        name = "safe_buffer___safe_buffer_5.2.1.tgz";
        url  = "https://registry.yarnpkg.com/safe-buffer/-/safe-buffer-5.2.1.tgz";
        sha1 = "1eaf9fa9bdb1fdd4ec75f58f9cdb4e6b7827eec6";
      };
    }
    {
      name = "semver___semver_5.7.1.tgz";
      path = fetchurl {
        name = "semver___semver_5.7.1.tgz";
        url  = "https://registry.yarnpkg.com/semver/-/semver-5.7.1.tgz";
        sha1 = "a954f931aeba508d307bbf069eff0c01c96116f7";
      };
    }
    {
      name = "source_map_support___source_map_support_0.5.21.tgz";
      path = fetchurl {
        name = "source_map_support___source_map_support_0.5.21.tgz";
        url  = "https://registry.yarnpkg.com/source-map-support/-/source-map-support-0.5.21.tgz";
        sha1 = "04fe7c7f9e1ed2d662233c28cb2b35b9f63f6e4f";
      };
    }
    {
      name = "source_map___source_map_0.6.1.tgz";
      path = fetchurl {
        name = "source_map___source_map_0.6.1.tgz";
        url  = "https://registry.yarnpkg.com/source-map/-/source-map-0.6.1.tgz";
        sha1 = "74722af32e9614e9c287a8d0bbde48b5e2f1a263";
      };
    }
    {
      name = "source_map___source_map_0.7.3.tgz";
      path = fetchurl {
        name = "source_map___source_map_0.7.3.tgz";
        url  = "https://registry.yarnpkg.com/source-map/-/source-map-0.7.3.tgz";
        sha1 = "5302f8169031735226544092e64981f751750383";
      };
    }
    {
      name = "stable___stable_0.1.8.tgz";
      path = fetchurl {
        name = "stable___stable_0.1.8.tgz";
        url  = "https://registry.yarnpkg.com/stable/-/stable-0.1.8.tgz";
        sha1 = "836eb3c8382fe2936feaf544631017ce7d47a3cf";
      };
    }
    {
      name = "supports_color___supports_color_5.5.0.tgz";
      path = fetchurl {
        name = "supports_color___supports_color_5.5.0.tgz";
        url  = "https://registry.yarnpkg.com/supports-color/-/supports-color-5.5.0.tgz";
        sha1 = "e2e69a44ac8772f78a1ec0b35b689df6530efc8f";
      };
    }
    {
      name = "supports_color___supports_color_7.2.0.tgz";
      path = fetchurl {
        name = "supports_color___supports_color_7.2.0.tgz";
        url  = "https://registry.yarnpkg.com/supports-color/-/supports-color-7.2.0.tgz";
        sha1 = "1b7dcdcb32b8138801b3e478ba6a51caa89648da";
      };
    }
    {
      name = "svgo___svgo_2.8.0.tgz";
      path = fetchurl {
        name = "svgo___svgo_2.8.0.tgz";
        url  = "https://registry.yarnpkg.com/svgo/-/svgo-2.8.0.tgz";
        sha1 = "4ff80cce6710dc2795f0c7c74101e6764cfccd24";
      };
    }
    {
      name = "term_size___term_size_2.2.1.tgz";
      path = fetchurl {
        name = "term_size___term_size_2.2.1.tgz";
        url  = "https://registry.yarnpkg.com/term-size/-/term-size-2.2.1.tgz";
        sha1 = "2a6a54840432c2fb6320fea0f415531e90189f54";
      };
    }
    {
      name = "terser___terser_5.12.1.tgz";
      path = fetchurl {
        name = "terser___terser_5.12.1.tgz";
        url  = "https://registry.yarnpkg.com/terser/-/terser-5.12.1.tgz";
        sha1 = "4cf2ebed1f5bceef5c83b9f60104ac4a78b49e9c";
      };
    }
    {
      name = "timsort___timsort_0.3.0.tgz";
      path = fetchurl {
        name = "timsort___timsort_0.3.0.tgz";
        url  = "https://registry.yarnpkg.com/timsort/-/timsort-0.3.0.tgz";
        sha1 = "405411a8e7e6339fe64db9a234de11dc31e02bd4";
      };
    }
    {
      name = "type_fest___type_fest_0.20.2.tgz";
      path = fetchurl {
        name = "type_fest___type_fest_0.20.2.tgz";
        url  = "https://registry.yarnpkg.com/type-fest/-/type-fest-0.20.2.tgz";
        sha1 = "1bf207f4b28f91583666cb5fbd327887301cd5f4";
      };
    }
    {
      name = "typescript___typescript_3.9.10.tgz";
      path = fetchurl {
        name = "typescript___typescript_3.9.10.tgz";
        url  = "https://registry.yarnpkg.com/typescript/-/typescript-3.9.10.tgz";
        sha1 = "70f3910ac7a51ed6bef79da7800690b19bf778b8";
      };
    }
    {
      name = "utility_types___utility_types_3.10.0.tgz";
      path = fetchurl {
        name = "utility_types___utility_types_3.10.0.tgz";
        url  = "https://registry.yarnpkg.com/utility-types/-/utility-types-3.10.0.tgz";
        sha1 = "ea4148f9a741015f05ed74fd615e1d20e6bed82b";
      };
    }
    {
      name = "v8_compile_cache___v8_compile_cache_2.3.0.tgz";
      path = fetchurl {
        name = "v8_compile_cache___v8_compile_cache_2.3.0.tgz";
        url  = "https://registry.yarnpkg.com/v8-compile-cache/-/v8-compile-cache-2.3.0.tgz";
        sha1 = "2de19618c66dc247dcfb6f99338035d8245a2cee";
      };
    }
    {
      name = "weak_lru_cache___weak_lru_cache_1.2.2.tgz";
      path = fetchurl {
        name = "weak_lru_cache___weak_lru_cache_1.2.2.tgz";
        url  = "https://registry.yarnpkg.com/weak-lru-cache/-/weak-lru-cache-1.2.2.tgz";
        sha1 = "fdbb6741f36bae9540d12f480ce8254060dccd19";
      };
    }
    {
      name = "xxhash_wasm___xxhash_wasm_0.4.2.tgz";
      path = fetchurl {
        name = "xxhash_wasm___xxhash_wasm_0.4.2.tgz";
        url  = "https://registry.yarnpkg.com/xxhash-wasm/-/xxhash-wasm-0.4.2.tgz";
        sha1 = "752398c131a4dd407b5132ba62ad372029be6f79";
      };
    }
    {
      name = "yaml___yaml_1.10.2.tgz";
      path = fetchurl {
        name = "yaml___yaml_1.10.2.tgz";
        url  = "https://registry.yarnpkg.com/yaml/-/yaml-1.10.2.tgz";
        sha1 = "2301c5ffbf12b467de8da2333a459e29e7920e4b";
      };
    }
  ];
}
