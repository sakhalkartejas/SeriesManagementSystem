using System;

namespace SeriesManagement.BAL
{
    public class SeriesValidationException : Exception
    {
        public SeriesValidationException(string message) : base(message)
        {
        }
    }
}
