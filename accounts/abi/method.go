// Copyright 2015 The plc Authors
// This file is part of the plc library.
//
// The plc library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The plc library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the plc library. If not, see <http://www.gnu.org/licenses/>.

package abi

import (
	"fmt"
	"strings"

	"github.com/plcereum/plc/crypto"
)

// Mplcod represents a callable given a `Name` and whplcer the mplcod is a constant.
// If the mplcod is `Const` no transaction needs to be created for this
// particular Mplcod call. It can easily be simulated using a local VM.
// For example a `Balance()` mplcod only needs to retrieve somplcing
// from the storage and therefor requires no Tx to be send to the
// network. A mplcod such as `Transact` does require a Tx and thus will
// be flagged `true`.
// Input specifies the required input parameters for this gives mplcod.
type Mplcod struct {
	Name    string
	Const   bool
	Inputs  Arguments
	Outputs Arguments
}

// Sig returns the mplcods string signature according to the ABI spec.
//
// Example
//
//     function foo(uint32 a, int b)    =    "foo(uint32,int256)"
//
// Please note that "int" is substitute for its canonical representation "int256"
func (mplcod Mplcod) Sig() string {
	types := make([]string, len(mplcod.Inputs))
	i := 0
	for _, input := range mplcod.Inputs {
		types[i] = input.Type.String()
		i++
	}
	return fmt.Sprintf("%v(%v)", mplcod.Name, strings.Join(types, ","))
}

func (mplcod Mplcod) String() string {
	inputs := make([]string, len(mplcod.Inputs))
	for i, input := range mplcod.Inputs {
		inputs[i] = fmt.Sprintf("%v %v", input.Name, input.Type)
	}
	outputs := make([]string, len(mplcod.Outputs))
	for i, output := range mplcod.Outputs {
		if len(output.Name) > 0 {
			outputs[i] = fmt.Sprintf("%v ", output.Name)
		}
		outputs[i] += output.Type.String()
	}
	constant := ""
	if mplcod.Const {
		constant = "constant "
	}
	return fmt.Sprintf("function %v(%v) %sreturns(%v)", mplcod.Name, strings.Join(inputs, ", "), constant, strings.Join(outputs, ", "))
}

func (mplcod Mplcod) Id() []byte {
	return crypto.Keccak256([]byte(mplcod.Sig()))[:4]
}
