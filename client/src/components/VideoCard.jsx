import React, { useState } from "react";

import DeleteForeverIcon from "@mui/icons-material/DeleteForever";
import ThumbUpOffAltIcon from "@mui/icons-material/ThumbUpOffAlt";
import ThumbUpIcon from "@mui/icons-material/ThumbUp";
import ThumbDownOffAltIcon from "@mui/icons-material/ThumbDownOffAlt";
import ThumbDownIcon from "@mui/icons-material/ThumbDown";
import ConvertToEmbedUrl from "../functions/Embed"

function VideoCard(props) {
  const deleteIcon = <DeleteForeverIcon />;
  const up = <ThumbUpIcon />;
  const upA = <ThumbUpOffAltIcon />;
  const down = <ThumbDownIcon />;
  const downA = <ThumbDownOffAltIcon />;

  const [like, setLike] = useState(0);
  const [dislike, setDislike] = useState(0);
  const [rate, setRate] = useState(props.rating);
  const embedUrl = ConvertToEmbedUrl(props.url)

  const dateString = props.date;
  const date = new Date(dateString);

  const day = date.getDate().toString().padStart(2, '0');
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const year = date.getFullYear().toString();

  const formattedDate = `${day}.${month}.${year}`;

  return (
    <div className="card" style={{ width: "330px", height: "350px" }}>
      <iframe
        width="auto"
        height="315"
        src={`https://www.youtube.com/embed/${embedUrl}`}
        title="YouTube video player"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowFullScreen
      ></iframe>
      <div className="card-body">
        <p className="card-text">{props.title}</p>
        <br></br>
        <p>Added on {formattedDate}</p>
      </div>
      <ul className="list-group list-group-flush">
        <li className="list-group-item">
          <button
            onClick={() => {
              if (like === 1) {
                setLike(0);
                setRate(rate - 1);
              }
              if (like === 0) {
                setLike(1);
                setRate(rate + 1);
              }
            }}
          >
            {like === 1 ? up : upA}
            <br></br>Like
          </button>
          <button
            onClick={() => {
              if (dislike === 1) {
                setDislike(0);
                setRate(rate + 1);
              }
              if (dislike === 0 && props.rating !== 0) {
                setDislike(1);
                setRate(rate - 1);
              }
            }}
          >
            {dislike === 1 ? down : downA}
            <br></br>Disike
          </button>
          <button onClick={props.delete}>
            {deleteIcon}
            <br></br>Delete
          </button>
        </li>
        <li className="list-group-item">{rate}</li>
      </ul>
    </div>
  );
}

export default VideoCard;
