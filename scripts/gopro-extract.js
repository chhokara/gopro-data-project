const { Storage } = require("@google-cloud/storage");
const gpmfExtract = require("gpmf-extract");

const storage = new Storage();

(async () => {
  try {
    const RAW_BUCKET_NAME = process.env.RAW_BUCKET_NAME;
    const OBJECT_NAME = process.env.OBJECT_NAME;
    const CURATED_BUCKET = process.env.CURATED_BUCKET;
    const OUT_PREFIX = process.env.OUT_PREFIX || "gpmf/";

    if (!RAW_BUCKET_NAME || !OBJECT_NAME || !CURATED_BUCKET) {
      throw new Error("Missing required environment variables.");
    }

    if (!OBJECT_NAME.toLowerCase().endsWith(".mp4")) {
      console.log("The object is not an MP4 file. Exiting.");
      process.exit(0);
    }

    console.log(
      `Starting extraction for gs://${RAW_BUCKET_NAME}/${OBJECT_NAME}`
    );

    const [buf] = await storage
      .bucket(RAW_BUCKET_NAME)
      .file(OBJECT_NAME)
      .download();
    const uint8Array = new Uint8Array(buf);

    const result = await gpmfExtract(uint8Array);

    if (!result || !result.rawData || result.rawData.length === 0) {
      console.log("No GPMF data found in the video.");
      process.exit(0);
    }

    const base = OBJECT_NAME.replace(/^.*[\\/]/, "").replace(/\.mp4$/i, "");
    const outGpmd = `${OUT_PREFIX}${base}.gpmd`;
    const outTiming = `${OUT_PREFIX}${base}_timing.json`;

    await storage
      .bucket(CURATED_BUCKET)
      .file(outGpmd)
      .save(Buffer.from(result.rawData), {
        contentType: "application/octet-stream",
        resumable: false,
      });

    await storage
      .bucket(CURATED_BUCKET)
      .file(outTiming)
      .save(JSON.stringify(result.timing || {}, null, 2), {
        contentType: "application/json",
        resumable: false,
      });

    console.log(`Wrote GPMF data to gs://${CURATED_BUCKET}/${outGpmd}`);
    console.log(`Wrote timing data to gs://${CURATED_BUCKET}/${outTiming}`);
  } catch (e) {
    console.error("Error during extraction:", e);
    process.exit(1);
  }
})();
