#[macro_use]
extern crate ruru;
extern crate notify;

use ruru::{Class, RString, Object, AnyObject, NilClass};
use std::thread;
use std::process::exit;
use notify::{RecommendedWatcher, Watcher};
use std::sync::mpsc::channel;

fn watch(top_path: String, pipe_in: AnyObject, pipe_out: AnyObject) -> notify::Result<()> {
    let (tx, rx) = channel();
    let mut watcher: RecommendedWatcher = try!(Watcher::new(tx));
    try!(watcher.watch(&top_path));

    thread::spawn(move || {
        pipe_in.send("readchar", vec![]);
        exit(0);
    });

    loop {
        match rx.recv() {
            Ok(notify::Event{ path: Some(path),op: Ok(op) }) => {
                pipe_out.send("puts", vec![RString::new(&format!("{:?}~~~{:?}", op, path)).to_any_object()]);
            },
            Err(e) => println!("watch error {}", e),
            _ => ()
        }
    }
}

class!(RustWatcher);
methods!(
    RustWatcher,
    itself,
    fn notify_watch(pipe_in: AnyObject, pipe_out: AnyObject) -> NilClass {
        let path = itself.send("path", vec![]).try_convert_to::<RString>().unwrap().to_string();
        let _ = watch(path, pipe_in.unwrap(), pipe_out.unwrap());
        NilClass::new()
    }
);

#[no_mangle]
pub extern fn init_rust_watcher() {
    Class::from_existing("RustWatcher").define(|itself| {
        itself.def("watch_binding", notify_watch);
    });
}
