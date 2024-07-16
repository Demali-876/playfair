# `playfair`

This is repository contains an implementation of the `playfair` algorithm in the Motoko programming language, designed to run on the Internet Computer Protocol (ICP). The playfair algorithm is a polyalphabetic substitution cipher. This encryption technique was used as a means for secure communication by the British and later by the United States during World War I as a field cipher.

## Introduction

This implementation if for educational purposes only and is not intended to be used as a secure form of encryption(obviously). This code should not regarded as production ready, this algorithm is not secure and is only applicable for basic obfuscation.

You can read my article explaining how the algorithm works [here](https://medium.com/@demaligregg123/recreating-a-world-war-i-cryptographic-algorithm-in-motoko-ef545e97560d)

To learn more before you start experimenting with `playfair`, see the following documentation available online:

- [Quick Start](https://internetcomputer.org/docs/current/developer-docs/setup/deploy-locally)
- [SDK Developer Tools](https://internetcomputer.org/docs/current/developer-docs/setup/install)
- [Motoko Programming Language Guide](https://internetcomputer.org/docs/current/motoko/main/motoko)
- [Motoko Language Quick Reference](https://internetcomputer.org/docs/current/motoko/main/language-manual)

If you want to start working on your project right away, you might want to try the following commands:

```bash
cd playfair/
dfx help
dfx canister --help
```

## Running the project locally

If you want to test your project locally, you can use the following commands:

```bash
# Starts the replica, running in the background
dfx start --background

# Deploys your canisters to the replica and generates your candid interface
dfx deploy
```

Once the job completes, your application will be available at `http://localhost:4943?canisterId={asset_canister_id}`.
