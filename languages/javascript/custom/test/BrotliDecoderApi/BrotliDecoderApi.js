const zlib = require("zlib");

zlib.brotliDecompress(data);
zlib.brotliDecompressSync(data);
zlib.createBrotliDecompress();
new zlib.BrotliDecompress();

const { iterdecompressBrotli, decompressBrotliSync } = require("zlib/iterdecompressBrotli");
iterdecompressBrotli(data);
decompressBrotliSync(data);

new DecompressionStream("brotli");
new DecompressionStream(format);

fetch(url);
new EventSource(url);
new WebSocket(url);

tls.connect({ certificateCompression: "brotli" });
tls.connect({ certificateCompression: compression });

express.json();
express.raw();
express.text();
express.urlencoded();
bodyParser.json();
bodyParser.raw();
bodyParser.text();
bodyParser.urlencoded();

// Constant non-Brotli formats and unrelated similarly named APIs are not matches.
new DecompressionStream("gzip");
tls.connect({ certificateCompression: "zlib" });
router.json();
router.raw();
unzip(data);
