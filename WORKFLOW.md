This document explains the workflow structure of the project. As the project improves and the directory structure solidifies, it will likely be absorbed by README.md

## Project workflow

### Data
Test data will be saved for now in the main repository. The project will be designed in a modular way, such that new data can be "plugged in" to the main function and data won't necessarily be stored on GitHub.

### Workflow
Right now, 
- init.R runs initialization (read in secret API keys)
- calculate-fim.R runs brunt of calculations.


However, there's several improvements I'd like to make to calculate-fim.R. For now, it's using the FRED API to read in potential GDP. I'd preferably like the calculate-fim script to *only* run calculations, not to read in data. There can be a different script called update-data.R that does that stuff, including potential GDP. So I'd like to move the "calculate neutral" section to a new update-data.R script.

In calculate-fim, I want the only input to be an excel sheet (or something) containing all types of data: potential GDP; forecasts and historical data fo transfers, taxes and purchases; mpcs. a different script can handle updating all of that data.



flow:
1. have a template excel sheet with:
    - potential GDP
    - forecasts
    - historical
    - MPCs (must be able to change over time)
        how do I change MPCs with time? One idea I have is to have a sheet called MPCs. each MPC gets an ID number from 001 to N. So, for example, MPC 1 could be (0.5, 0.2, 0.1), MPC 2 could be (0.02, 0.02, 0.02, 0.02), and MPC 3 could be (0.8, 0.1, 0.1). I could even consider giving them nicknames (like mpc-rebate-pre2021 and mpc-rebate-post2021), for example.
        Then, I'd have a new table. For every variable for each data variable, I list out every year-quarter. So I'd have medicare, social security, corporate taxes, federal purchases, etc as a row with every year-quarter from 1970 Q1 to 2026 Q1 as columns. I can specify the ID number of the MPC to be applied to the data disbursed up to that point. (So, suppose 100 of ARP is distributed in Q2 2020 with MPC 003 and 100 of ARP is distributed in Q3 2020 with MPC 004. Imagine that MPC 003 = (0.5, 0.5, 0) and MPC 004 = (0.02, 0.02, 0.02, 0.02, 0.02). Then this is how it would look in the FIM. Q2 2020 would be 100\*0.5, since MPC 003 is applied to 100, and we assume no carry-overs from the past. What happens in Q3 2020? Well, we have 0.5\*100 carryover from the prior quarter, since we're in the second quarter of MPC 003. We then add this to 0.02\*100, which is the MPC 004 first quarter. So overall we have 50 + 2 = 52 for quarter 3 FIM amount of money that gassed up the economy.)


**Why do we do we subtract neutral growth first, then apply MPCs?**
Let's imagine the following. $100 transfers was distributed in 2020 Q1. the neutral growth rate was 2% (not annualized). So, neutrally speaking, we expect $102 transfers in 2020 Q2. That would add 0 to the FIM. Instead, we get $122 transfers because of COVID. So, we have stimulated the FIM by $20.
Why do we do the minus neutral in that quarter? Wouldn't it make sense to calculate the MPC of the spending of it, and then do the minus neutral of each MPC chunk? Like, let's say the MPC on transfers is (0.1, 0.1, 0.1, 0.1 ... 0.1). 
If we do minus neutral first, we'd find that we have $20 extra disbursed. Since MPC in any given quarter is 0.1, we'd only disburse $2 per quarter. That is the direct stimulative effect on GDP. It adds $2 to GDP. Interesting. Makes sense.
But the amount of money normally disbursed, shouldn't we have applied an MPC to it already and see how much our new MPC'ed cash compares to the old cash? For example, suppose for the past 100 years, exactly $100 has been disbursed per quarter.
And suppose that MPC was always (0.1, 0.1, 0.1... 0.1) up until it sums to 1.
So post-MPC, we'd always have $100 spent per quarter. makes sense. That of course would subtract from the FIM if potential GDP grows faster than 0.
What do we want to know? How much is the money spent this quarter adding to or subtracting from GDP?

ok, now think about this. Suppose the MPC is (0.5, 0.5) making it simple.
This is the time flow of disbursements:
|                                  | 2018 Q3 | 2018 Q4 | 2019 Q1 | 2019 Q2 | 2019 Q3 | 2019 Q4 | 2020 Q1 | 2020 Q2 |
|----------------------------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Disbursed                        |  100    | 100     | 100     | 50      | 50      | 20      | 120     | 140     |
| Cumulative calculation           | .5\*100 (for simplicity) + 0.5\*100 | .5\*100 + .5\*100 | .5\*100 + .5\*100 | .5\*100 + .5\*50 | .5\*50 + .5\*50 | .5\*50 + .5\*20 | 0.5\*20 + 0.5\*120 | 0.5\*120 + 0.5\*140 |
| Cumulative value                 |  100    | 100     | 100     | 75      | 50      | 35      | 70      | 130     |

The cumulative value here is the actual amount of cash that's being added to the economy. So shouldn't we calculate that first?

Here's a different thought experiment. (show an example where disbursements grow at potential but somehow cumulative value is not growing at potential - either above or below).
|                                  | 2018 Q3 | 2018 Q4 | 2019 Q1 | 2019 Q2 | 2019 Q3 | 2019 Q4 | 2020 Q1 | 2020 Q2 |
|----------------------------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Disbursed                        |  100    | 110     | 121     | 133.1   | 146.41  | 161.051 | 177.1561   | 194.87171  |
| Disbursed growth from previous quarter |  10%    | 10%     | 10%     | 10%     | 10%     |10%      | 10%      | 10%      |
| Potential GDP growth from previous quarter |  10%    | 10%     | 10%     | 10%     | 10%     |10%      | 10%      | 10%      |
| Cumulative calculation           | .5\*100 (for sake of simplicity) + 0.5\*100 | .5\*100 + .5\*110 | .5\*110 + .5\*121 | .5\*121 + .5\*131.1 | .5\*131.1 + .5\*146.41 | .5\*146.41 + .5\*161.051 | 0.5\*161.051 + 0.5\*177.1561 | 0.5\*177.1561 + 0.5\*194.87171 |
| Cumulative value                 |  100    | 105     | 115.5    | 126.05   | 138.755   | 153.7305    | 169.10355 | 186.013905 |


