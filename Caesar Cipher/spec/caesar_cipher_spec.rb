# spec/caesar_cipher_spec.rb
require './caesar_cipher'

describe '#caesar_cipher' do
  describe 'basic shifting' do
    it 'shifts lowercase letters' do
      expect(caesar_cipher('abc', 1)).to eq('bcd')
    end

    it 'shifts uppercase letters' do
      expect(caesar_cipher('ABC', 1)).to eq('BCD')
    end

    it 'shifts mixed case' do
      expect(caesar_cipher('AbC', 1)).to eq('BcD')
    end
  end

  describe 'wrapping around the alphabet' do
    it 'wraps lowercase z to a' do
      expect(caesar_cipher('xyz', 3)).to eq('abc')
    end

    it 'wraps uppercase Z to A' do
      expect(caesar_cipher('XYZ', 3)).to eq('ABC')
    end
  end

  describe 'non-alphabetic characters' do
    it 'leaves spaces unchanged' do
      expect(caesar_cipher('a b c', 1)).to eq('b c d')
    end

    it 'leaves punctuation unchanged' do
      expect(caesar_cipher('a!b?c.', 1)).to eq('b!c?d.')
    end

    it 'leaves numbers unchanged' do
      expect(caesar_cipher('a1b2c3', 1)).to eq('b1c2d3')
    end
  end

  describe 'large shifts' do
    it 'handles shifts greater than 26' do
      expect(caesar_cipher('abc', 27)).to eq('bcd')
    end

    it 'handles shifts of exactly 26' do
      expect(caesar_cipher('abc', 26)).to eq('abc')
    end

  end

  describe 'edge cases' do
    it 'handles empty string' do
      expect(caesar_cipher('', 5)).to eq('')
    end

  end

  describe 'negative shifts' do
    it 'shifts backwards' do
      expect(caesar_cipher('bcd', -1)).to eq('abc')
    end

    it 'wraps backwards from a to z' do
      expect(caesar_cipher('abc', -3)).to eq('xyz')
    end
  end
end
