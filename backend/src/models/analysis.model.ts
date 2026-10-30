import mongoose, { Document, Schema, Types } from 'mongoose';

export interface IClassProbability {
  code: string;
  name: string;
  probability: number;
  riskLevel: 'Low' | 'Moderate' | 'High';
  description?: string;
}

export interface IAnalysis {
  userId: Types.ObjectId;
  imageUrl?: string | null;
  imageFileName?: string | null;
  imageSizeBytes?: number | null;
  imageMimeType?: string | null;
  modelVersion: string;
  predictedClass: string;
  conditionName: string;
  confidence: number;
  lowConfidence: boolean;
  riskLevel: 'Low' | 'Moderate' | 'High';
  probabilities: IClassProbability[];
  summary: string;
  clinicalRecommendations: string[];
  dimensions?: { width: number; height: number };
  imageMetrics?: {
    asymmetryScore: number;
    borderIrregularity: number;
    colorVariance: number;
    pigmentDensity: number;
  };
  createdAt: Date;
  updatedAt: Date;
}

export interface IAnalysisDocument extends IAnalysis, Document {}

const ClassProbabilitySchema = new Schema<IClassProbability>(
  {
    code: { type: String, required: true },
    name: { type: String, required: true },
    probability: { type: Number, required: true, min: 0, max: 1 },
    riskLevel: { type: String, enum: ['Low', 'Moderate', 'High'], required: true },
    description: { type: String },
  },
  { _id: false }
);

const AnalysisSchema = new Schema<IAnalysisDocument>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'User ID is required'],
      index: true,
    },
    imageUrl: {
      type: String,
      default: null,
      trim: true,
    },
    imageFileName: {
      type: String,
      default: null,
      trim: true,
    },
    imageSizeBytes: {
      type: Number,
      default: null,
    },
    imageMimeType: {
      type: String,
      default: null,
    },
    modelVersion: {
      type: String,
      required: [true, 'Model version is required'],
      trim: true,
      default: 'HAM10000-ResNet50-v2.3.0',
    },
    predictedClass: {
      type: String,
      required: [true, 'Predicted class code is required'],
      trim: true,
    },
    conditionName: {
      type: String,
      required: [true, 'Condition name is required'],
      trim: true,
    },
    confidence: {
      type: Number,
      required: [true, 'Confidence score is required'],
      min: 0,
      max: 100,
    },
    lowConfidence: {
      type: Boolean,
      required: true,
      default: false,
    },
    riskLevel: {
      type: String,
      enum: ['Low', 'Moderate', 'High'],
      required: true,
      default: 'Low',
    },
    probabilities: {
      type: [ClassProbabilitySchema],
      default: [],
    },
    summary: {
      type: String,
      required: [true, 'Clinical summary is required'],
      trim: true,
    },
    clinicalRecommendations: {
      type: [String],
      default: [],
    },
    dimensions: {
      width: { type: Number },
      height: { type: Number },
    },
    imageMetrics: {
      asymmetryScore: { type: Number },
      borderIrregularity: { type: Number },
      colorVariance: { type: Number },
      pigmentDensity: { type: Number },
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_, ret: Record<string, unknown>) => {
        delete ret['__v'];
        return ret;
      },
    },
  }
);

// Compound index for user query sorting
AnalysisSchema.index({ userId: 1, createdAt: -1 });

export const Analysis = mongoose.model<IAnalysisDocument>('Analysis', AnalysisSchema);
