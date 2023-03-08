ifeq (, $(shell which jq))
$(error You need to install jq)
endif

turn_contract_title := turn.turn

all: .parameterized

plutus.json: validators/*.ak
	aiken build

.parameterized: plutus.json
	$(eval turn_contract := $(shell jq -r '.validators[] | select(.title=="$(turn_contract_title)") .hash' plutus.json))
	aiken blueprint apply -m mint_board.mint_board . '(con bytestring #$(turn_contract))'
	@touch .parameterized

.PHONY: clean
clean:
	rm -f .parameterized plutus.json