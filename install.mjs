#!/usr/bin/env -S node

// Script to install CyberRE in your game's directory.
// 
// Usage: node install.mjs [game-path]
import * as fs from 'fs';

const options = process.argv.slice(2);

const PLUGIN_NAME = 'RedMemoryDump';
const GAME_PATH = options.length > 0 ? options[0] : 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\Cyberpunk 2077';
const RED4EXT_PATH = `${GAME_PATH}\\red4ext\\plugins`;
const REDSCRIPT_PATH = `${GAME_PATH}\\r6\\scripts`;
const CET_SCRIPT_PATH = `${GAME_PATH}\\bin\\x64\\plugins\\cyber_engine_tweaks\\mods`;

// Whether game directory exists?
if (!fs.existsSync(GAME_PATH)) {
    console.error(`[${PLUGIN_NAME}] Could not find game directory at: ${GAME_PATH}`);
    process.exit(1);
}

// Whether RED4ext directory exists?
if (!fs.existsSync(RED4EXT_PATH)) {
    console.error(`[${PLUGIN_NAME}] Could not find RED4ext directory at: ${RED4EXT_PATH}`);
    console.info('[${PLUGIN_NAME}] Install RED4ext from https://docs.red4ext.com/getting-started/installing-red4ext');
    process.exit(2);
}

// Whether Redscript directory exists?
if (!fs.existsSync(REDSCRIPT_PATH)) {
    console.error(`[${PLUGIN_NAME}] Could not find Redscript directory at: ${REDSCRIPT_PATH}`);
    console.info('[${PLUGIN_NAME}] Install Redscript from https://wiki.redmodding.org/redscript/getting-started/downloads');
    process.exit(3);
}

// Whether CET directory exists?
if (!fs.existsSync(CET_SCRIPT_PATH)) {
    console.error(`[${PLUGIN_NAME}] Could not find CET scripts directory at: ${CET_SCRIPT_PATH}`);
    console.info('[${PLUGIN_NAME}] Install CET from https://wiki.redmodding.org/cyber-engine-tweaks/getting-started/installing');
    process.exit(4);
}

const GAME_PLUGIN_PATH = `${RED4EXT_PATH}\\${PLUGIN_NAME}`;
const GAME_REDSCRIPT_PATH = `${REDSCRIPT_PATH}\\${PLUGIN_NAME}`;
const GAME_CET_SCRIPT_PATH = `${CET_SCRIPT_PATH}\\${PLUGIN_NAME}`;

// Optionally create plugin's directory.
if (!fs.existsSync(GAME_PLUGIN_PATH)) {
    fs.mkdirSync(GAME_PLUGIN_PATH);
    console.info(`[${PLUGIN_NAME}] Plugin directory created at: ${GAME_PLUGIN_PATH}`);
}

// Delete all redscripts, to prevent old (removed) scripts to persist.
fs.rmSync(GAME_REDSCRIPT_PATH, {force: true, recursive: true});
fs.mkdirSync(GAME_REDSCRIPT_PATH);
console.info(`[${PLUGIN_NAME}] Red scripts directory created at: ${GAME_REDSCRIPT_PATH}`);

try {
    // Delete all CET scripts, to prevent old (removed) scripts to persist.
    fs.rmSync(GAME_CET_SCRIPT_PATH, {force: true, recursive: true});
    fs.mkdirSync(GAME_CET_SCRIPT_PATH);
    console.info(`[${PLUGIN_NAME}] CET scripts directory created at: ${GAME_CET_SCRIPT_PATH}`);
} catch (error) {
    console.warn(`[${PLUGIN_NAME}] CET scripts directory not refreshed at: ${GAME_CET_SCRIPT_PATH}`);
}

const BUILD_LIBRARY_PATH = `build\\Debug\\${PLUGIN_NAME}.dll`;
const GAME_LIBRARY_PATH = `${GAME_PLUGIN_PATH}\\${PLUGIN_NAME}.dll`;

try {
    fs.cpSync(BUILD_LIBRARY_PATH, GAME_LIBRARY_PATH, {force: true});
    console.info(`[${PLUGIN_NAME}] Library installed.`);
} catch (error) {
    console.info(`[${PLUGIN_NAME}] Library not refreshed.`);
}

const BUILD_REDSCRIPT_PATH = `scripts\\redscript\\${PLUGIN_NAME}`;
const BUILD_CET_SCRIPT_PATH = `scripts\\cet\\`;

fs.cpSync(BUILD_REDSCRIPT_PATH, GAME_REDSCRIPT_PATH, {force: true, recursive: true, preserveTimestamps: true})
fs.cpSync(BUILD_CET_SCRIPT_PATH, GAME_CET_SCRIPT_PATH, {force: true, recursive: true, preserveTimestamps: true});
console.info(`[${PLUGIN_NAME}] Scripts installed.`);