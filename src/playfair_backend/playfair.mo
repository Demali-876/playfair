import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Char "mo:base/Char";

actor PlayFair {
    private let ALPHABET = "ABCDEFGHIKLMNOPQRSTUVWXYZ";
    private type KeySquare = [[Text]];
    private type Position = (Nat, Nat);

    private func create_key_square(key : Text) : (KeySquare, HashMap.HashMap<Text, Position>) {
        let keySquare = Buffer.Buffer<Buffer.Buffer<Text>>(5);
        let keyPos = HashMap.HashMap<Text, Position>(25, Text.equal, Text.hash);

        // Initialize the buffers
        var i = 0;
        while (i < 5) {
            keySquare.add(Buffer.Buffer<Text>(5));
            i += 1;
        };

        let keyInHashMap = func (k : Text) : Bool {
            switch (keyPos.get(k)) {
                case (null) { false };
                case (_) { true };
            }
        };

        var row = 0;
        var col = 0;

        //add character to key square
        let addToKeySquare = func (char : Text) {
            let rowBuffer = keySquare.get(row);
            rowBuffer.add(char);
            keyPos.put(char, (row, col));
            col += 1;
            if (col == 5) {
                row += 1;
                col := 0;
            }
        };

        // Process the Key
        label processKeyLoop for (char in Text.toIter(Text.toUppercase(Text.trim(key, #char ' ')))) {
            let charText = Text.fromChar(char);
            if (Char.isAlphabetic(char) and charText != "J" and not keyInHashMap(charText)) {
                addToKeySquare(charText);
                if (row == 5) { break processKeyLoop; }
            }
        };
        // Fill in the rest of the alphabet
        label fillAlphabetLoop for (char in Text.toIter(ALPHABET)) {
            let charText = Text.fromChar(char);
            if (not keyInHashMap(charText)) {
                addToKeySquare(charText);
                if (row == 5) { break fillAlphabetLoop; }
            }
        };
        // Convert buffer of buffers to immutable 2D array
        let frozenKeySquare : KeySquare = Array.tabulate<[Text]>(5, func (i : Nat) : [Text] {
            let rowBuffer = keySquare.get(i);
            Array.tabulate<Text>(5, func (j : Nat) : Text {
                rowBuffer.get(j)
            })
        });
        (frozenKeySquare, keyPos)
    };

    private func preprocess_text(text : Text) : Text {
    // First, trim spaces and convert to uppercase
    // Explicitly remove all spaces
    let noSpaces = Text.toUppercase(Text.replace(text, #char ' ', ""));
    
    let processed = Buffer.Buffer<Text>(noSpaces.size());
    let chars = Text.toIter(noSpaces);

    var previousChar : ?Text = null;

    label l while (true) {
        let charOpt = chars.next();
        switch (charOpt) {
            case (?char) {
                let currentChar = if (char == 'J') "I" else Text.fromChar(char);
                switch (previousChar) {
                    case (?prevChar) {
                        if (prevChar == currentChar) {
                            processed.add(prevChar);
                            processed.add("X");
                            processed.add(currentChar);
                            previousChar := null;
                        } else {
                            processed.add(prevChar);
                            processed.add(currentChar);
                            previousChar := null;
                        }
                    };
                    case (null) {
                        switch (chars.next()) {
                            case (?nextChar) {
                                let nextProcessedChar = if (nextChar == 'J') "I" else Text.fromChar(nextChar);
                                if (currentChar == nextProcessedChar) {
                                    processed.add(currentChar);
                                    processed.add("X");
                                    previousChar := ?nextProcessedChar;
                                } else {
                                    processed.add(currentChar);
                                    processed.add(nextProcessedChar);
                                    previousChar := null;
                                }
                            };
                            case (null) {
                                processed.add(currentChar);
                                processed.add("X");
                                previousChar := null;
                            };
                        };
                    };
                }
            };
            case (null) { break l; };
        }
    };
    Text.join("", processed.vals())
    };

    private func encrypt_pair(pair : (Text, Text), keySquare : KeySquare, keyPos : HashMap.HashMap<Text, Position>) : (Text, Text) {
        let (char1, char2) = pair;
        let (r1, c1) = switch (keyPos.get(char1)) {
            case (?pos) { pos };
            case (null) { return (char1, char2) };
        };
        let (r2, c2) = switch (keyPos.get(char2)) {
            case (?pos) { pos };
            case (null) { return (char1, char2) };
        };

        if (r1 == r2) {
            (keySquare[r1][(c1 + 1) % 5], keySquare[r2][(c2 + 1) % 5])
        } else if (c1 == c2) {
            (keySquare[(r1 + 1) % 5][c1], keySquare[(r2 + 1) % 5][c2])
        } else {
            (keySquare[r1][c2], keySquare[r2][c1])
        }
    };

    public func playfair_encrypt(text : Text, key : Text) : async Text {
        let (keySquare, keyPos) = create_key_square(key);
        let preprocessed = preprocess_text(text);
        let encrypted = Buffer.Buffer<Text>(preprocessed.size());

        let chars = Text.toIter(preprocessed);
        label l while (true) {
            switch (chars.next(), chars.next()) {
                case (?c1, ?c2) {
                    let (enc1, enc2) = encrypt_pair((Text.fromChar(c1), Text.fromChar(c2)), keySquare, keyPos);
                    encrypted.add(enc1);
                    encrypted.add(enc2);
                };
                case (?c1, null) {
                    encrypted.add(Text.fromChar(c1));
                    break l;
                };
                case (_, _) {
                    break l;
                };
            };
        };

        Text.join("", encrypted.vals())
    };
    private func decrypt_pair(pair : (Text, Text), keySquare : KeySquare, keyPos : HashMap.HashMap<Text, Position>) : (Text, Text) {
        let (char1, char2) = pair;
        let (r1, c1) = switch (keyPos.get(char1)) {
            case (?pos) { pos };
            case (null) { return (char1, char2) };
        };
        let (r2, c2) = switch (keyPos.get(char2)) {
            case (?pos) { pos };
            case (null) { return (char1, char2) };
        };

        if (r1 == r2) {
            (keySquare[r1][(c1 + 4) % 5], keySquare[r2][(c2 + 4) % 5])
        } else if (c1 == c2) {
            (keySquare[(r1 + 4) % 5][c1], keySquare[(r2 + 4) % 5][c2])
        } else {
            (keySquare[r1][c2], keySquare[r2][c1])
        }
    };

    public func playfair_decrypt(text : Text, key : Text) : async Text {
        let (keySquare, keyPos) = create_key_square(key);
        let decrypted = Buffer.Buffer<Text>(text.size());

        let chars = Text.toIter(text);
        label l while (true) {
            switch (chars.next(), chars.next()) {
                case (?c1, ?c2) {
                    let (dec1, dec2) = decrypt_pair((Text.fromChar(c1), Text.fromChar(c2)), keySquare, keyPos);
                    decrypted.add(dec1);
                    decrypted.add(dec2);
                };
                case (?c1, null) {
                    decrypted.add(Text.fromChar(c1));
                    break l;
                };
                case (_, _) {
                    break l;
                };
            };
        };
        // Remove padding 'X's, except when between two same letters
        let finalText = Buffer.Buffer<Text>(decrypted.size());
        var i = 0;
        while (i < decrypted.size()) {
            if (i < Nat.sub(decrypted.size(), 2) and decrypted.get(i + 1) == "X" and decrypted.get(i) == decrypted.get(i + 2)) {
                finalText.add(decrypted.get(i));
                finalText.add(decrypted.get(i + 2));
                i += 3;
            } else {
                finalText.add(decrypted.get(i));
                i += 1;
            };
        };
        Text.join("", finalText.vals())
    };
};