const { Storage } = require("@google-cloud/storage");
const gpmfExtract = require("gpmf-extract");
const goproTelemetry = require("gopro-telemetry");

const storage = new Storage();

(async () => {
  try {
    const RAW_BUCKET = process.env.RAW_BUCKET;
    const OBJECT_NAME = process.env.OBJECT_NAME;
    const CURATED_BUCKET = process.env.CURATED_BUCKET;
    const OUT_PREFIX = process.env.OUT_PREFIX || "gpmf/";

    if (!RAW_BUCKET || !OBJECT_NAME || !CURATED_BUCKET) {
      throw new Error("Missing required environment variables.");
    }

    if (!OBJECT_NAME.toLowerCase().endsWith(".mp4")) {
      console.log(OBJECT_NAME + " is not an MP4 file.");
      process.exit(0);
    }

    console.log(`Starting extraction for gs://${RAW_BUCKET}/${OBJECT_NAME}`);

    const [buf] = await storage.bucket(RAW_BUCKET).file(OBJECT_NAME).download();

    const result = await gpmfExtract(buf);

    if (!result || !result.rawData || result.rawData.length === 0) {
      console.log("No GPMF data found in the video.");
      process.exit(0);
    }

    const telemetry = await goproTelemetry(result, {
      stream: ["ACCL", "GYRO", "GPS"],
    });

    console.log(
      "acceleration samples:",
      telemetry["1"]["streams"]["ACCL"]["samples"].slice(0, 5)
    );

    console.log(
      "gyroscope samples:",
      telemetry["1"]["streams"]["GYRO"]["samples"].slice(0, 5)
    );

    console.log(
      "GPS samples:",
      telemetry["1"]["streams"]["GPS"]["samples"].slice(0, 5)
    );
  } catch (e) {
    console.error("Error during extraction:", e);
    process.exit(1);
  }
})();
