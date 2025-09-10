//
// Copyright (c) 2022 ZettaScale Technology
//
// This program and the accompanying materials are made available under the
// terms of the Eclipse Public License 2.0 which is available at
// http://www.eclipse.org/legal/epl-2.0, or the Apache License, Version 2.0
// which is available at https://www.apache.org/licenses/LICENSE-2.0.
//
// SPDX-License-Identifier: EPL-2.0 OR Apache-2.0
//
// Contributors:
//   ZettaScale Zenoh Team, <zenoh@zettascale.tech>
//

#include <chrono>
#include <cstdio>
#include <iostream>
#include <thread>

#include "../getargs.hxx"
#include "zenoh.hxx"

using namespace zenoh;
using namespace std::chrono_literals;

int _main(int argc, char **argv) {
    auto &&[config, args] = ConfigCliArgParser(argc, argv).named_flag({"no-express"}, "Disable message batching").run();

    std::cout << "Opening session...\n";
    auto session = Session::open(std::move(config));

    Session::PublisherOptions opts;
    opts.is_express = args.flag("no-express");
    auto pub = session.declare_publisher(KeyExpr("test/pong"), std::move(opts));
    session.declare_background_subscriber(
        KeyExpr("test/ping"),
        [pub = std::move(pub)](const Sample &sample) mutable { pub.put(sample.get_payload().clone()); },
        closures::none);

    std::cout << "Pong ready, press CTRL-C to quit...\n";
    while (true) {
        std::this_thread::sleep_for(1s);
    }
    return 0;
}

int main(int argc, char **argv) {
    try {
#ifdef ZENOHCXX_ZENOHC
        init_log_from_env_or("error");
#endif
        _main(argc, argv);
    } catch (ZException e) {
        std::cout << "Received an error :" << e.what() << "\n";
    }
}
