<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    use HasFactory;

    protected $fillable = [
        'session_id', 'student_id', 'status', 'method', 'checked_at', 'distance', 'image_path',
    ];

    protected $casts = [
        'checked_at' => 'datetime',
        'distance' => 'float',
    ];

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function student()
    {
        return $this->belongsTo(User::class, 'student_id');
    }
}
