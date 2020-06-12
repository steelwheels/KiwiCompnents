/**
 * @file	KMComponent.swift
 * @brief	Define KMComponent protocol
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

public protocol KMComponent
{
	func setup(script scr: KMObject, input inhdl: FileHandle, output outhdl: FileHandle, error errhdl: FileHandle)
}

