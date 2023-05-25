const express = require('express');
const morgan = require("morgan");

const app = express();

const port = process.env.PORT || 8080;

app.use(morgan('dev'));

app.get('/', (req, res) => {
    res.send('Hi there: let\'s switch to BLUE!');
});

app.listen(port, () => {
    console.log(`App listening on port ${port}`);
});
