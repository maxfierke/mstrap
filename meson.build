project('mstrap',
  'c',
  meson_version : '>= 0.60.0',
  license : 'MIT',
  version : '0.4.0',
  default_options : [
    'buildtype=debugoptimized',
    'default_library=static'
  ]
)

target_arch = host_machine.cpu_family()
target_system = host_machine.system()
target_triple = target_arch + '-unknown-' + target_system

buildtype = get_option('buildtype')
is_darwin = target_system == 'darwin'
is_static = get_option('default_library') == 'static'
is_static_libc = false

if target_system == 'linux'
  target_cabi = meson.get_external_property('target_triple_suffix', 'gnu')

  target_triple += '-' + target_cabi

  if target_cabi == 'musl' and is_static
    is_static_libc = true
    add_global_link_arguments('-static', language : 'c')
  endif
elif target_system == 'darwin'
  macos_abi = meson.get_external_property('macos_version', '11')
  macos_arch = target_arch == 'aarch64' ? 'arm64' : target_arch

  target_triple = macos_arch + '-apple-macos' + macos_abi
  add_global_arguments('-target', target_triple, language : 'c', native : false)
  add_global_link_arguments('-target', target_triple, language : 'c', native : false)
endif

cc = meson.get_compiler('c')
crystal = find_program('crystal', required : true)
shards = find_program('shards', required : true)

# Basics
libiconv_dep = dependency('iconv', static : is_static and not is_darwin)
libm_dep = cc.find_library('m', required : false, static : is_static)
libpcre_dep = dependency('libpcre', static : is_static)
thread_dep = dependency('threads', static : is_static)
zlib_dep = dependency('zlib', static : is_static and not is_darwin)

# OpenSSL/LibreSSL (for fetching profiles & strap.sh over HTTPS)
libcrypto_dep = dependency('libcrypto', version : '>= 1.1.1', static : is_static)
libssl_dep = dependency('libssl', version : '>= 1.1.1', static : is_static)

embedded_openssl = libcrypto_dep.type_name() != 'pkgconfig'

if embedded_openssl
  pkg = import('pkgconfig')
  pkg.generate(
    name : 'libcrypto',
    description: 'OpenSSL-libcrypto',
    version : libcrypto_dep.version(),
    libraries : [libcrypto_dep]
  )
  pkg.generate(
    name : 'libssl',
    description: 'OpenSSL-libssl',
    version : libssl_dep.version(),
    libraries : [libssl_dep]
  )
endif

# Libevent (required for Crystal runtime)
libevent_dep = dependency(
  'libevent',
  version : '>= 2.1.2',
  static : is_static,
  required : false,
)
if not libevent_dep.found()
  cmake = import('cmake')
  libevent_options = cmake.subproject_options()
  libevent_options.add_cmake_defines({
    'EVENT__LIBRARY_TYPE': 'STATIC',
    'BUILD_SHARED_LIBS': false,
    'BUILD_SHARED_AND_STATIC_LIBS': false,
    'CMAKE_C_FLAGS':  '-fPIC',
    'EVENT__DISABLE_OPENSSL': true,
    'EVENT__DISABLE_BENCHMARK': true,
    'EVENT__DISABLE_TESTS': true,
    'EVENT__DISABLE_REGRESS': true,
    'EVENT__DISABLE_SAMPLES': true,
  })
  libevent_options.set_override_option('werror', 'false')
  libevent_options.set_override_option('warning_level', '0')
  libevent_proj = cmake.subproject('libevent', options: libevent_options)
  libevent_dep = libevent_proj.dependency('event_core_static')
endif

# libgc (required for Crystal runtime)
libgc_dep = dependency(
  'bdw-gc',
  version : '>= 8.0.4',
  static : is_static,
  required : false
)
if not libgc_dep.found()
  cmake = import('cmake')
  libgc_options = cmake.subproject_options()
  libgc_options.add_cmake_defines({
    'BUILD_SHARED_LIBS': false,
    'enable_docs': false,
    'enable_large_config': true,
    'disable_gc_debug': true,
    'CMAKE_C_FLAGS':  '-fPIC',
  })
  libgc_options.set_override_option('werror', 'false')
  libgc_options.set_override_option('warning_level', '0')
  libgc_proj = cmake.subproject('bdwgc', options: libgc_options)
  libgc_dep = libgc_proj.dependency('gc')
endif

if run_command(shards, 'check', check : false).returncode() != 0
  run_command(shards, 'install', '--frozen', check : true)
endif

crystal_path = run_command(
  crystal, 'env', 'CRYSTAL_PATH',
  check : true
).stdout().strip()
env = environment({
  'CRYSTAL_PATH': crystal_path,
})
env.prepend('CRYSTAL_PATH', join_paths(meson.project_source_root(), 'lib'))

if embedded_openssl
  env.set('PKG_CONFIG_PATH', join_paths(meson.project_build_root(), 'meson-uninstalled'))
endif

crystal_build_flags = [
  '--cross-compile',
  '--target',
  target_triple,
]

if buildtype.contains('debug')
  crystal_build_flags += ['--debug', '--error-trace']
else
  crystal_build_flags += ['--no-debug']
endif

if buildtype in ['release', 'debugoptimized']
  crystal_build_flags += ['--release']
endif

if is_static_libc
  crystal_build_flags += ['--static']
endif

mstrap_build_cmd = [crystal, 'build'] + crystal_build_flags + ['-o', 'mstrap', '@INPUT@']

mstrap_o = custom_target(
  'mstrap.o',
  build_always_stale : true,
  command : mstrap_build_cmd,
  depend_files : [files('shard.lock')],
  env : env,
  input : [files('src/cli.cr')],
  output : ['mstrap.o']
)

executable(
  'mstrap',
  mstrap_o,
  dependencies : [
    libcrypto_dep,
    libevent_dep,
    libgc_dep,
    libiconv_dep,
    libm_dep,
    libpcre_dep,
    libssl_dep,
    zlib_dep,
    thread_dep
  ],
)
