<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FaceSample extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'path', 'embedding', 'quality_score',
    ];

    protected $casts = [
        'embedding' => 'array',
        'quality_score' => 'float',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
