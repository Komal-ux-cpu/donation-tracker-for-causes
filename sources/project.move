module MyModule::SimpleCrowdfunding {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a crowdfunding campaign
    struct Campaign has store, key {
        goal: u64,           // Target amount to raise
        raised: u64,         // Current amount raised
        active: bool,        // Campaign status
    }

    /// Error codes
    const E_CAMPAIGN_INACTIVE: u64 = 1;
    const E_INVALID_AMOUNT: u64 = 2;

    /// Function 1: Initialize a new crowdfunding campaign
    public fun create_campaign(
        creator: &signer, 
        funding_goal: u64
    ) {
        let campaign = Campaign {
            goal: funding_goal,
            raised: 0,
            active: true,
        };
        move_to(creator, campaign);
    }

    /// Function 2: Contribute funds to an existing campaign
    public fun contribute(
        contributor: &signer,
        campaign_owner: address,
        amount: u64
    ) acquires Campaign {
        // Validate contribution amount
        assert!(amount > 0, E_INVALID_AMOUNT);
        
        // Get campaign reference
        let campaign = borrow_global_mut<Campaign>(campaign_owner);
        
        // Check if campaign is active
        assert!(campaign.active, E_CAMPAIGN_INACTIVE);
        
        // Transfer coins from contributor to campaign owner
        let contribution = coin::withdraw<AptosCoin>(contributor, amount);
        coin::deposit<AptosCoin>(campaign_owner, contribution);
        
        // Update raised amount
        campaign.raised = campaign.raised + amount;
        
        // Deactivate campaign if goal is reached
        if (campaign.raised >= campaign.goal) {
            campaign.active = false;
        };
    }
}