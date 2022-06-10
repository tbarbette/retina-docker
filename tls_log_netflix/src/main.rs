use retina_core::config::load_config;
use retina_core::Runtime;
use retina_core::subscription::TlsHandshake;
use retina_filtergen::filter;

use clap::Parser;

use std::fs::File;
use std::io::{BufWriter, Write};
use std::path::PathBuf;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Mutex;

#[derive(Parser, Debug)]
struct Args {
    #[clap(short, long, parse(from_os_str), value_name = "FILE")]
    config: PathBuf,
    #[clap(
        short,
        long,
        parse(from_os_str),
        value_name = "FILE",
        default_value = "tls.jsonl"
    )]
    outfile: PathBuf,
}

#[filter("tls.sni ~ '(.+?\\.)?nflxvideo\\.net'")]
fn main() {
    env_logger::init();
    let args = Args::parse();
    let config = load_config(&args.config);
    let cnt = AtomicUsize::new(0);
    let file = Mutex::new(BufWriter::new(
        File::create(&args.outfile).expect("Error creating file"),
    ));
    let callback = |tls: TlsHandshake| {
        log::info!("{:#?}", tls);
        if let Ok(json) = serde_json::to_string(&tls) {
            let mut json_bufwtr = file.lock().unwrap();
            json_bufwtr.write_all(json.as_bytes()).unwrap();
            json_bufwtr.write_all(b"\n").unwrap();
        }
        cnt.fetch_add(1, Ordering::Relaxed);
    };
    let mut runtime = Runtime::new(config, filter, callback).unwrap();
    runtime.run();
    drop(runtime);
    let mut json_bufwtr = file.lock().unwrap();
    json_bufwtr.flush().unwrap();
    println!(
        "Done. Logged {:?} TLS handshakes to {:?}",
        cnt, &args.outfile
    );
}