<h2><?php echo $text_payment_info; ?></h2>
<div class="alert alert-success" id="bluepay_redirect_transaction_msg" style="display:none;"></div>
<table class="table table-striped table-bordered">
  <tr>
    <td><?php echo $text_order_ref; ?></td>
    <td><?php echo $bluepay_redirect_order['transaction_id']; ?></td>
  </tr>
  <tr>
    <td><?php echo $text_order_total; ?></td>
    <td><?php echo $bluepay_redirect_order['total_formatted']; ?></td>
  </tr>
  <tr>
    <td><?php echo $text_total_released; ?></td>
    <td id="bluepay_redirect_total_released"><?php echo $bluepay_redirect_order['total_released_formatted']; ?></td>
  </tr>
  <tr>
    <td><?php echo $text_release_status; ?></td>
    <td id="release_status"><?php if ($bluepay_redirect_order['release_status'] == 1) { ?>
      <span class="release_text"><?php echo $text_yes; ?></span>
      <?php } else { ?>
      <span class="release_text"><?php echo $text_no; ?></span>&nbsp;&nbsp;
      <?php if ($bluepay_redirect_order['void_status'] == 0) { ?>
      <input type="text" width="10" id="release_amount" value="<?php echo $bluepay_redirect_order['total']; ?>"/>
      <a class="button btn btn-primary" id="button-release"><?php echo $button_release; ?></a> <span class="btn btn-primary" id="img_loading_release" style="display:none;"><i class="fa fa-circle-o-notch fa-spin fa-lg"></i></span>
      <?php } ?>
      <?php } ?></td>
  </tr>
  <tr>
    <td><?php echo $text_void_status; ?></td>
    <td id="void_status"><?php if ($bluepay_redirect_order['void_status'] == 1) { ?>
      <span class="void_text"><?php echo $text_yes; ?></span>
      <?php } elseif ($bluepay_redirect_order['void_status'] == 0 && $bluepay_redirect_order['release_status'] == 1 && $bluepay_redirect_order['rebate_status'] != 1) { ?>
      <span class="void_text"><?php echo $text_no; ?></span>&nbsp;&nbsp; <a class="button btn btn-primary" id="button-void"><?php echo $button_void; ?></a> <span class="btn btn-primary" id="img_loading_void" style="display:none;"><i class="fa fa-circle-o-notch fa-spin fa-lg"></i></span>
      <?php } else { ?>
      <span class="void_text"><?php echo $text_no; ?></span>
      <?php } ?></td>
  </tr>
  <tr>
    <td><?php echo $text_rebate_status; ?></td>
    <td id="rebate_status"><?php if ($bluepay_redirect_order['rebate_status'] == 1) { ?>
      <span class="rebate_text"><?php echo $text_yes; ?></span>
      <?php } else { ?>
      <span class="rebate_text"><?php echo $text_no; ?></span>&nbsp;&nbsp;
      <?php if ($bluepay_redirect_order['total_released'] > 0 && $bluepay_redirect_order['void_status'] == 0 && $bluepay_redirect_order['release_status'] == 1) { ?>
      <input type="text" width="10" id="rebate_amount" />
      <a class="button btn btn-primary" id="button-rebate"><?php echo $button_rebate; ?></a> <span class="btn btn-primary" id="img_loading_rebate" style="display:none;"><i class="fa fa-circle-o-notch fa-spin fa-lg"></i></span>
      <?php } ?>
      <?php } ?></td>
  </tr>
  <tr>
    <td><?php echo $text_transactions; ?>:</td>
    <td><table class="table table-striped table-bordered" id="bluepay_redirect_transactions">
        <thead>
          <tr>
            <td class="text-left"><strong><?php echo $text_column_date_added; ?></strong></td>
            <td class="text-left"><strong><?php echo $text_column_type; ?></strong></td>
            <td class="text-left"><strong><?php echo $text_column_amount; ?></strong></td>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($bluepay_redirect_order['transactions'] as $transaction) { ?>
          <tr>
            <td class="text-left"><?php echo $transaction['date_added']; ?></td>
            <td class="text-left"><?php echo $transaction['type']; ?></td>
            <td class="text-left"><?php echo $transaction['amount']; ?></td>
          </tr>
          <?php } ?>
        </tbody>
      </table></td>
  </tr>
</table>
<script type="text/javascript"><!--
	$(document).on('click', '#button-void', function(){
		if (confirm('<?php echo $text_confirm_void; ?>')) {
			$.ajax({
				type: 'POST',
				dataType: 'json',
				data: {'order_id': <?php echo $order_id; ?>},
				url: 'index.php?route=extension/payment/bluepay_redirect/void&token=<?php echo $token; ?>',
				beforeSend: function() {
					$('#button-void').hide();
					$('#img_loading_void').show();
					$('#bluepay_redirect_transaction_msg').hide();
				},
				success: function(data) {
					if (data.error == false) {
						html = '';
						html += '<tr>';
						html += '<td class="text-left">' + data.data.date_added + '</td>';
						html += '<td class="text-left">void</td>';
						html += '<td class="text-left">' + data.data.total + '</td>';
						html += '</tr>';

						$('.void_text').text('<?php echo $text_yes; ?>');
						$('.rebate_text').text('<?php echo $text_no; ?>');
						$('#bluepay_redirect_transactions').append(html);
						$('#button-release').hide();
						$('#release_amount').hide();
						$('#button-rebate').hide();
						$('#rebate_amount').hide();

						if (data.msg != '') {
							$('#bluepay_redirect_transaction_msg').empty().html('<i class="fa fa-check-circle"></i> ' + data.msg).fadeIn();
						}
					}
					if (data.error == true) {
						alert(data.msg);
						$('#button-void').show();
					}

					$('#img_loading_void').hide();
				}
			});
		}
	});
	$(document).on('click', '#button-release', function(){
		if (confirm('<?php echo $text_confirm_release; ?>')) {
			$.ajax({
				type: 'POST',
				dataType: 'json',
				data: {'order_id': <?php echo $order_id; ?>, 'amount': $('#release_amount').val()},
				url: 'index.php?route=extension/payment/bluepay_redirect/release&token=<?php echo $token; ?>',
				beforeSend: function() {
					$('#button-release').hide();
					$('#release_amount').hide();
					$('#img_loading_release').show();
					$('#bluepay_redirect_transaction_msg').hide();
				},
				success: function(data) {
					if (data.error == false) {
						html = '';
						html += '<tr>';
						html += '<td class="text-left">' + data.data.date_added + '</td>';
						html += '<td class="text-left">payment</td>';
						html += '<td class="text-left">' + data.data.amount + '</td>';
						html += '</tr>';

						$('#bluepay_redirect_transactions').append(html);
						$('#bluepay_redirect_total_released').text(data.data.total);

						if (data.data.release_status == 1) {
							$('.void_text').after('<a style="margin-left: 10px;" id="button-void" class="button btn btn-primary">Void</a>');
							$('.rebate_text').after('<input style="margin-left: 10px;" width="10" type="text" id="rebate_amount"><a style="margin-left: 5px;" id="button-rebate" class="button btn btn-primary">Rebate / refund</a>');
							$('.release_text').text('<?php echo $text_yes; ?>');
							$('#rebate_amount').val(0.00).show();
						} else {
							$('#button-release').show();
							$('#release_amount').val(0.00);

						}

						if (data.msg != '') {
							$('#bluepay_redirect_transaction_msg').empty().html('<i class="fa fa-check-circle"></i> ' + data.msg).fadeIn();
						}

						$('#button-rebate').show();
						$('#rebate_amount').val(0.00).show();
					}
					if (data.error == true) {
						alert(data.msg);
						$('#button-release').show();
						$('#release_amount').show();
					}

					$('#img_loading_release').hide();
				}
			});
		}
	});
	$(document).on('click', '#button-rebate', function(){
		if (confirm('<?php echo $text_confirm_rebate; ?>')) {
			$.ajax({
				type: 'POST',
				dataType: 'json',
				data: {'order_id': <?php echo $order_id; ?>, 'amount': $('#rebate_amount').val()},
				url: 'index.php?route=extension/payment/bluepay_redirect/rebate&token=<?php echo $token; ?>',
				beforeSend: function() {
					$('#button-rebate').hide();
					$('#rebate_amount').hide();
					$('#img_loading_rebate').show();
					$('#bluepay_redirect_transaction_msg').hide();
				},
				success: function(data) {
					if (data.error == false) {
						html = '';
						html += '<tr>';
						html += '<td class="text-left">' + data.data.date_added + '</td>';
						html += '<td class="text-left">rebate</td>';
						html += '<td class="text-left">' + data.data.amount + '</td>';
						html += '</tr>';

						$('#bluepay_redirect_transactions').append(html);
						$('#bluepay_redirect_total_released').text(data.data.total_released);

						if (data.data.rebate_status == 1) {
							$('.rebate_text').text('<?php echo $text_yes; ?>');
							$('#button-void').hide();
						} else {
							$('#button-rebate').show();
							$('#rebate_amount').show();
						}

						if (data.msg != '') {
							$('#bluepay_redirect_transaction_msg').empty().html('<i class="fa fa-check-circle"></i> ' + data.msg).fadeIn();
						}
					}
					if (data.error == true) {
						alert(data.msg);
						$('#button-rebate').show();
						$('#rebate_amount').show();
					}

					$('#img_loading_rebate').hide();
				}
			});
		}
	});
//--></script>