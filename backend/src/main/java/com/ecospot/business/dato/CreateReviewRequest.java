package com.ecospot.business.dato;

public class CreateReviewRequest {

  private Integer qualification;
  private String opinion;

  public CreateReviewRequest() {
  }

  public CreateReviewRequest(Integer qualification, String opinion) {
    this.qualification = qualification;
    this.opinion = opinion;
  }

  public Integer getQualification() {
    return qualification;
  }

  public void setQualification(Integer qualification) {
    this.qualification = qualification;
  }

  public String getOpinion() {
    return opinion;
  }

  public void setOpinion(String opinion) {
    this.opinion = opinion;
  }
}