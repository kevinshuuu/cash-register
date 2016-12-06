require_relative '../spec_helper'

describe Register do
  let(:register) { Register.new }

  describe '#new' do
    it 'creates a register with no money in it' do
      expect(register).to be_empty
    end
  end

  describe '#put' do
    context 'put nothing into the register' do
      it 'does not change the register' do
        register.put([0, 0, 0, 0, 0])
        expect(register).to be_empty
      end
    end

    context 'put money into the register' do
      it 'does change the register' do
        register.put([1, 1, 1, 1, 1])
        expect(register.total).to eq(38)
      end
    end

    context 'putting negative number of bills' do
      it 'raises ArgumentError' do
        expect{ register.put([0, 0, 0, 0, -1]) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#take' do
    context 'take nothing from the register' do
      it 'does not change the register' do
        register.take([0, 0, 0, 0, 0])
        expect(register).to be_empty
      end
    end

    context 'take a valid number of bills from the register' do
      before do
        register.put([1, 1, 1, 1, 1])
      end

      it 'takes the correct amount' do
        register.take([1, 1, 1, 1, 0])
        expect(register.total).to eq(1)
      end
    end

    context 'take an invalid number of bills from the register' do
      it 'does not take anything and restores the original bill state' do
        expect{ register.take([1, 0, 0, 0, 0]) }.to raise_error(Register::InsufficientBillsError)
        expect(register).to be_empty
      end
    end

    context 'taking negative number of bills' do
      it 'raises ArgumentError' do
        expect{ register.take([0, 0, 0, 0, -1]) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#total' do
    context 'empty register' do
      it 'returns 0' do
        expect(register.total).to eq(0)
      end
    end

    context 'non-empty register' do
      before do
        register.put([1, 1, 0, 0, 0])
      end

      it 'returns the register total' do
        expect(register.total).to eq(30)
      end
    end
  end

  describe '#change' do
    context 'valid change available' do
      before do
        register.put([1, 1, 1, 1, 1])
      end

      it 'returns the change (3)' do
        expect(register.change(3)).to eq([0, 0, 0, 1, 1])
        expect(register.total).to eq(35)
      end

      it 'returns the change (38)' do
        expect(register.change(38)).to eq([1, 1, 1, 1, 1])
        expect(register).to be_empty
      end
    end

    context 'multiple ways of making change' do
      before do
        register.put([0, 0, 1, 0, 5])
      end

      it 'returns the way of making change using the fewest bills' do
        expect(register.change(5)).to eq([0, 0, 1, 0, 0])
        expect(register.total).to eq(5)
      end
    end

    context 'invalid change available' do
      before do
        register.put([1, 1, 1, 1, 1])
      end

      it 'raises Register::InsufficientBillsError' do
        expect{ register.change(4) }.to raise_error(Register::InsufficientBillsError)
        expect(register.total).to eq(38)
      end
    end
  end
end
