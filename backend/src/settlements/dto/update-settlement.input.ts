import { CreateSettlementInput } from './create-settlement.input.js';
import { InputType, Field, Int, PartialType, Float } from '@nestjs/graphql';

@InputType()
export class UpdateSettlementInput extends PartialType(CreateSettlementInput) {
  @Field(() => Int)
  id: number;
  @Field(() => String, { description: 'Settlement status' })
  status: string;
  @Field(() => Float, { description: 'Settlement amount', nullable: true })
  amount?: number;
}
