# SocialStake Protocol

[![Stacks](https://img.shields.io/badge/Stacks-2.0-blue)](https://stacks.co)
[![Clarity](https://img.shields.io/badge/Clarity-3.0-purple)](https://clarity-lang.org)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen)](tests/)

> A revolutionary decentralized social networking protocol that transforms online interactions through cryptographic proof-of-stake mechanics, creating verifiable trust networks where influence is earned, not bought.

## 🌟 Overview

SocialStake introduces a paradigm shift in digital social interaction by combining blockchain immutability with economic incentives. Users must stake STX tokens to participate, creating a self-regulating ecosystem where quality content and genuine connections are naturally rewarded.

### Core Innovation

Unlike traditional social platforms driven by advertising models, SocialStake aligns user incentives with network health through economic commitment. The more users invest in their reputation and others' content, the stronger the network becomes, creating a virtuous cycle of value creation and authentic social capital accumulation.

## ✨ Key Features

- **🔐 Proof-of-Stake Social Mechanics**: Every interaction requires economic commitment
- **🏆 Dynamic Reputation System**: Transparent, tamper-proof influence metrics
- **💰 Economic Incentive Alignment**: Users earn by contributing quality content
- **🌐 Trust Network Creation**: Verifiable social relationships through staking
- **🚫 Spam Prevention**: Economic barriers eliminate low-quality interactions
- **📈 Network Effects**: Growing value as more users participate

## 🏗️ Architecture

### Smart Contract Structure

```text
contracts/
└── social-stake.clar    # Main protocol contract (674 lines)
```

### Core Components

1. **Profile Management**: User identity and reputation tracking
2. **Social Graph**: Following/follower relationships with metrics
3. **Content System**: Post creation and amplification mechanisms  
4. **Trust Validation**: Multi-layered endorsement system
5. **Economic Engine**: Stake requirements and reward distribution

## 🔧 Technical Specifications

### Stake Requirements

| Action | Minimum Stake | Purpose |
|--------|---------------|---------|
| Profile Creation | 1 STX | Identity verification barrier |
| Content Boost | 0.1 STX | Post amplification |
| Endorsements | 0.5 STX | Trust signal validation |

### Error Codes

```clarity
ERR_UNAUTHORIZED (100)       # Access denied
ERR_PROFILE_EXISTS (101)     # Duplicate profile
ERR_PROFILE_NOT_FOUND (102)  # Missing profile
ERR_INSUFFICIENT_FUNDS (103) # Insufficient STX balance
ERR_INVALID_AMOUNT (104)     # Below minimum stake
ERR_ALREADY_FOLLOWING (105)  # Duplicate follow attempt
ERR_NOT_FOLLOWING (106)      # Cannot unfollow non-followed user
ERR_SELF_FOLLOW (107)        # Self-following prevention
ERR_ALREADY_ENDORSED (108)   # Duplicate endorsement
ERR_POST_NOT_FOUND (109)     # Missing content
ERR_INVALID_POST_ID (110)    # Invalid post identifier
```

## 📋 Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) (v2.0+)
- [Node.js](https://nodejs.org) (v18+)
- [Stacks CLI](https://docs.stacks.co/stacks-cli) (for deployment)

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/isongsly/social-stake.git
cd social-stake

# Install dependencies
npm install

# Check contract syntax
clarinet check
```

### Development

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch

# Format contracts
clarinet fmt --in-place
```

## 📖 API Reference

### Core Functions

#### Profile Management

```clarity
;; Create a new user profile
(create-profile (username (string-ascii 50)) 
                (bio (string-utf8 280)) 
                (avatar-url (string-ascii 200)))

;; Update profile information
(update-profile (bio (string-utf8 280)) 
                (avatar-url (string-ascii 200)))

;; Increase reputation stake
(stake-for-reputation (amount uint))
```

#### Social Interactions

```clarity
;; Follow another user
(follow-user (following-id uint))

;; Unfollow a user
(unfollow-user (following-id uint))
```

#### Content Management

```clarity
;; Create new content
(create-post (content (string-utf8 500)))

;; Boost content visibility
(boost-post (post-id uint) (amount uint))
```

#### Trust & Endorsements

```clarity
;; Endorse content with stake
(endorse-post (post-id uint) (stake-amount uint))

;; Endorse user profile
(endorse-profile (endorsed-id uint) 
                 (stake-amount uint) 
                 (message (string-utf8 140)))
```

### Read-Only Functions

```clarity
;; Profile queries
(get-profile (profile-id uint))
(get-profile-by-username (username (string-ascii 50)))
(get-profile-by-principal (user principal))

;; Social graph queries
(is-following (follower-id uint) (following-id uint))

;; Content queries
(get-post (post-id uint))

;; Reputation calculation
(calculate-reputation-score (profile-id uint))
```

## 🧪 Testing

The protocol includes comprehensive test coverage using Vitest and Clarinet SDK:

```bash
# Run all tests
npm test

# Generate coverage report
npm run test:report

# Run specific test file
npx vitest run tests/social-stake.test.ts
```

### Test Structure

```text
tests/
└── social-stake.test.ts    # Comprehensive protocol tests
```

## 📊 Economic Model

### Reputation Calculation

The dynamic reputation score considers multiple factors:

```clarity
reputation = base_stake + 
             (follower_count × 1000) + 
             (endorsements × 2000) + 
             (post_count × 500)
```

### Stake Distribution

- **Profile Stakes**: Locked for identity verification
- **Content Boosts**: Distributed to content creators
- **Endorsement Stakes**: Locked as trust signals
- **Protocol Fees**: 1% (adjustable by contract owner)

## 🚀 Deployment

### Testnet Deployment

```bash
# Deploy to testnet
clarinet deployments apply --deployment-plan testnet

# Verify deployment
clarinet deployments describe --deployment-plan testnet
```

### Mainnet Deployment

```bash
# Generate deployment plan
clarinet deployments generate --mainnet

# Review and apply
clarinet deployments apply --deployment-plan mainnet
```

## 🔒 Security Considerations

- **Economic Barriers**: Prevent spam and sybil attacks
- **Stake Locking**: Ensures commitment to network health  
- **Access Controls**: Owner-only administrative functions
- **Input Validation**: Comprehensive parameter checking
- **Overflow Protection**: Safe arithmetic operations

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🗺️ Roadmap

- [ ] Multi-token staking support
- [ ] Governance mechanisms
- [ ] Content moderation tools
- [ ] Mobile SDK development
- [ ] Cross-chain bridging
- [ ] Advanced analytics dashboard
