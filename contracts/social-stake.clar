;; SocialStake Protocol
;;
;; Summary:
;; A revolutionary decentralized social networking protocol that transforms online
;; interactions through cryptographic proof-of-stake mechanics, creating verifiable
;; trust networks where influence is earned, not bought.
;;
;; Description:
;; SocialStake introduces a paradigm shift in digital social interaction by combining
;; blockchain immutability with economic incentives. Users must stake STX tokens to
;; participate, creating a self-regulating ecosystem where quality content and genuine
;; connections are naturally rewarded. Every social actionfrom profile creation to
;; content endorsement requires skin in the game, eliminating spam and fostering
;; authentic engagement. The protocol calculates dynamic reputation scores based on
;; stake weight, network effects, and peer validation, creating transparent influence
;; metrics that can't be manipulated or faked.
;;
;; Core Innovation:
;; Unlike traditional social platforms driven by advertising models, SocialStake aligns
;; user incentives with network health through economic commitment. The more users invest
;; in their reputation and others' content, the stronger the network becomes, creating
;; a virtuous cycle of value creation and authentic social capital accumulation.

;; CONTRACT CONSTANTS & ERROR CODES

(define-constant CONTRACT_OWNER tx-sender)

;; Error codes for comprehensive error handling
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PROFILE_EXISTS (err u101))
(define-constant ERR_PROFILE_NOT_FOUND (err u102))
(define-constant ERR_INSUFFICIENT_FUNDS (err u103))
(define-constant ERR_INVALID_AMOUNT (err u104))
(define-constant ERR_ALREADY_FOLLOWING (err u105))
(define-constant ERR_NOT_FOLLOWING (err u106))
(define-constant ERR_SELF_FOLLOW (err u107))
(define-constant ERR_ALREADY_ENDORSED (err u108))
(define-constant ERR_POST_NOT_FOUND (err u109))
(define-constant ERR_INVALID_POST_ID (err u110))

;; Stake requirements (in microSTX for precision)
(define-constant MIN_PROFILE_STAKE u1000000) ;; 1 STX - Profile creation barrier
(define-constant MIN_POST_BOOST u100000) ;; 0.1 STX - Content amplification
(define-constant MIN_ENDORSEMENT_STAKE u500000) ;; 0.5 STX - Trust validation

;; PROTOCOL STATE VARIABLES

(define-data-var next-profile-id uint u1)
(define-data-var next-post-id uint u1)
(define-data-var protocol-fee-rate uint u100) ;; 100 basis points = 1%

;; CORE DATA STRUCTURES

;; Comprehensive user profile with reputation metrics
(define-map profiles
  { profile-id: uint }
  {
    owner: principal,
    username: (string-ascii 50),
    bio: (string-utf8 280),
    avatar-url: (string-ascii 200),
    created-at: uint,
    staked-amount: uint,
    reputation-score: uint,
    follower-count: uint,
    following-count: uint,
    post-count: uint,
    total-endorsements: uint,
    is-active: bool,
  }
)

;; Identity resolution mappings
(define-map username-to-profile
  (string-ascii 50)
  uint
)
(define-map principal-to-profile
  principal
  uint
)

;; Social graph relationship tracking
(define-map following
  {
    follower: uint,
    following: uint,
  }
  {
    followed-at: uint,
    is-active: bool,
  }
)

;; Content storage with engagement metrics
(define-map posts
  { post-id: uint }
  {
    author: uint,
    content: (string-utf8 500),
    created-at: uint,
    boosted-amount: uint,
    endorsement-count: uint,
    is-active: bool,
  }
)

;; Endorsement tracking for content validation
(define-map post-endorsements
  {
    post-id: uint,
    endorser: uint,
  }
  {
    endorsed-at: uint,
    stake-amount: uint,
  }
)

;; Cross-profile trust validation system
(define-map profile-endorsements
  {
    endorser: uint,
    endorsed: uint,
  }
  {
    endorsed-at: uint,
    stake-amount: uint,
    message: (string-utf8 140),
  }
)

;; Economic stake tracking for reputation calculations
(define-map profile-stakes
  {
    profile-id: uint,
    staker: principal,
  }
  {
    amount: uint,
    staked-at: uint,
  }
)

;; Content amplification stake tracking
(define-map post-boosts
  {
    post-id: uint,
    booster: principal,
  }
  {
    amount: uint,
    boosted-at: uint,
  }
)

;; READ-ONLY QUERY FUNCTIONS

;; Profile retrieval by unique identifier
(define-read-only (get-profile (profile-id uint))
  (map-get? profiles { profile-id: profile-id })
)

;; Username-based profile lookup
(define-read-only (get-profile-by-username (username (string-ascii 50)))
  (match (map-get? username-to-profile username)
    profile-id (get-profile profile-id)
    none
  )
)

;; Principal-based profile resolution
(define-read-only (get-profile-by-principal (user principal))
  (match (map-get? principal-to-profile user)
    profile-id (get-profile profile-id)
    none
  )
)

;; Username availability check for registration
(define-read-only (is-username-available (username (string-ascii 50)))
  (is-none (map-get? username-to-profile username))
)

;; Social relationship verification
(define-read-only (is-following
    (follower-id uint)
    (following-id uint)
  )
  (match (map-get? following {
    follower: follower-id,
    following: following-id,
  })
    follow-data (get is-active follow-data)
    false
  )
)

;; Content retrieval by post identifier
(define-read-only (get-post (post-id uint))
  (map-get? posts { post-id: post-id })
)

;; System state queries
(define-read-only (get-next-profile-id)
  (var-get next-profile-id)
)

(define-read-only (get-next-post-id)
  (var-get next-post-id)
)

;; Dynamic reputation calculation algorithm
(define-read-only (calculate-reputation-score (profile-id uint))
  (match (get-profile profile-id)
    profile-data (let (
        (base-score (get staked-amount profile-data))
        (follower-bonus (* (get follower-count profile-data) u1000))
        (endorsement-bonus (* (get total-endorsements profile-data) u2000))
        (post-bonus (* (get post-count profile-data) u500))
      )
      (+ base-score (+ follower-bonus (+ endorsement-bonus post-bonus)))
    )
    u0
  )
)

;; PROFILE MANAGEMENT FUNCTIONS

;; Create new user profile with initial stake requirement
(define-public (create-profile
    (username (string-ascii 50))
    (bio (string-utf8 280))
    (avatar-url (string-ascii 200))
  )
  (let (
      (profile-id (var-get next-profile-id))
      (current-block stacks-block-height)
    )
    ;; Validation: Ensure unique profile per principal
    (asserts! (is-none (map-get? principal-to-profile tx-sender))
      ERR_PROFILE_EXISTS
    )

    ;; Validation: Username uniqueness
    (asserts! (is-username-available username) ERR_PROFILE_EXISTS)

    ;; Economic barrier: Verify stake capability
    (asserts! (>= (stx-get-balance tx-sender) MIN_PROFILE_STAKE)
      ERR_INSUFFICIENT_FUNDS
    )

    ;; Economic commitment: Transfer stake to contract
    (try! (stx-transfer? MIN_PROFILE_STAKE tx-sender (as-contract tx-sender)))

    ;; Profile creation with initial metrics
    (map-set profiles { profile-id: profile-id } {
      owner: tx-sender,
      username: username,
      bio: bio,
      avatar-url: avatar-url,
      created-at: current-block,
      staked-amount: MIN_PROFILE_STAKE,
      reputation-score: MIN_PROFILE_STAKE,
      follower-count: u0,
      following-count: u0,
      post-count: u0,
      total-endorsements: u0,
      is-active: true,
    })

    ;; Identity mapping establishment
    (map-set username-to-profile username profile-id)
    (map-set principal-to-profile tx-sender profile-id)
    (map-set profile-stakes {
      profile-id: profile-id,
      staker: tx-sender,
    } {
      amount: MIN_PROFILE_STAKE,
      staked-at: current-block,
    })

    ;; State progression
    (var-set next-profile-id (+ profile-id u1))

    (ok profile-id)
  )
)

;; Profile information updates (bio and avatar)
(define-public (update-profile
    (bio (string-utf8 280))
    (avatar-url (string-ascii 200))
  )
  (let ((profile-result (map-get? principal-to-profile tx-sender)))
    (match profile-result
      profile-id (match (get-profile profile-id)
        profile-data (begin
          (map-set profiles { profile-id: profile-id }
            (merge profile-data {
              bio: bio,
              avatar-url: avatar-url,
            })
          )
          (ok true)
        )
        ERR_PROFILE_NOT_FOUND
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Additional reputation staking mechanism
(define-public (stake-for-reputation (amount uint))
  (let (
      (profile-result (map-get? principal-to-profile tx-sender))
      (current-block stacks-block-height)
    )
    ;; Validation: Minimum stake requirement
    (asserts! (>= amount MIN_POST_BOOST) ERR_INVALID_AMOUNT)

    ;; Validation: Balance sufficiency
    (asserts! (>= (stx-get-balance tx-sender) amount) ERR_INSUFFICIENT_FUNDS)

    (match profile-result
      profile-id (begin
        ;; Economic commitment
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

        ;; Reputation enhancement
        (match (get-profile profile-id)
          profile-data (map-set profiles { profile-id: profile-id }
            (merge profile-data { staked-amount: (+ (get staked-amount profile-data) amount) })
          )
          false
        )

        ;; Stake tracking
        (map-set profile-stakes {
          profile-id: profile-id,
          staker: tx-sender,
        } {
          amount: amount,
          staked-at: current-block,
        })

        (ok true)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; SOCIAL GRAPH FUNCTIONS

;; Establish following relationship with metric updates
(define-public (follow-user (following-id uint))
  (let (
      (follower-profile-result (map-get? principal-to-profile tx-sender))
      (current-block stacks-block-height)
    )
    (match follower-profile-result
      follower-id (begin
        ;; Validation: Prevent self-following
        (asserts! (not (is-eq follower-id following-id)) ERR_SELF_FOLLOW)

        ;; Validation: Target profile existence
        (asserts! (is-some (get-profile following-id)) ERR_PROFILE_NOT_FOUND)

        ;; Validation: Prevent duplicate follows
        (asserts! (not (is-following follower-id following-id))
          ERR_ALREADY_FOLLOWING
        )

        ;; Relationship establishment
        (map-set following {
          follower: follower-id,
          following: following-id,
        } {
          followed-at: current-block,
          is-active: true,
        })

        ;; Follower count increment for target
        (match (get-profile following-id)
          following-profile (map-set profiles { profile-id: following-id }
            (merge following-profile { follower-count: (+ (get follower-count following-profile) u1) })
          )
          false
        )

        ;; Following count increment for initiator
        (match (get-profile follower-id)
          follower-profile (map-set profiles { profile-id: follower-id }
            (merge follower-profile { following-count: (+ (get following-count follower-profile) u1) })
          )
          false
        )

        (ok true)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)