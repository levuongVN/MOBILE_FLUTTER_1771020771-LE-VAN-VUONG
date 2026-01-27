import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  Court? _selectedCourt;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final bookingProvider = context.read<BookingProvider>();
    await bookingProvider.loadCourts();
    await _loadCalendar();

    if (bookingProvider.courts.isNotEmpty) {
      setState(() {
        _selectedCourt = bookingProvider.courts.first;
      });
    }
  }

  Future<void> _loadCalendar() async {
    final from = _focusedDay.subtract(const Duration(days: 7));
    final to = _focusedDay.add(const Duration(days: 14));
    await context.read<BookingProvider>().loadCalendar(from, to);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt sân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showMyBookings,
            tooltip: 'Booking của tôi',
          ),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, booking, _) {
          return LoadingOverlay(
            isLoading: booking.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCalendar(),
                  const SizedBox(height: 16),
                  _buildCourtSelector(booking.courts),
                  const SizedBox(height: 16),
                  _buildTimeSelector(),
                  const SizedBox(height: 16),
                  _buildBookingSummary(),
                  const SizedBox(height: 16),
                  _buildBookingSlots(booking.calendarSlots),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Đặt sân',
                    icon: Icons.check,
                    onPressed: _createBooking,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar() {
    return GlassCard(
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 30)),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _loadCalendar();
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          _loadCalendar();
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: ThemeProvider.primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: ThemeProvider.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildCourtSelector(List<Court> courts) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn sân',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (courts.isEmpty)
            const Text('Không có sân nào')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: courts.map((court) {
                final isSelected = _selectedCourt?.id == court.id;
                return ChoiceChip(
                  label: Text(court.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCourt = court;
                    });
                  },
                  selectedColor: ThemeProvider.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                  ),
                );
              }).toList(),
            ),
          if (_selectedCourt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_selectedCourt!.pricePerHour)}/giờ',
              style: TextStyle(
                color: ThemeProvider.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn giờ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeButton(
                  'Từ',
                  _startTime,
                  (time) => setState(() => _startTime = time),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeButton(
                  'Đến',
                  _endTime,
                  (time) => setState(() => _endTime = time),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    if (_selectedCourt == null) return const SizedBox();

    final startDateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      _endTime.hour,
      _endTime.minute,
    );

    final hours = endDateTime.difference(startDateTime).inMinutes / 60;
    final totalPrice = hours * _selectedCourt!.pricePerHour;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tóm tắt',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ngày'),
              Text(
                DateFormat('dd/MM/yyyy').format(_selectedDay),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sân'),
              Text(
                _selectedCourt!.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thời gian'),
              Text(
                '${hours.toStringAsFixed(1)} giờ',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: '₫',
                ).format(totalPrice),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeProvider.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSlots(List<CalendarSlot> slots) {
    final daySlots = slots
        .where(
          (s) =>
              s.startTime.year == _selectedDay.year &&
              s.startTime.month == _selectedDay.month &&
              s.startTime.day == _selectedDay.day &&
              (_selectedCourt == null || s.courtId == _selectedCourt!.id),
        )
        .toList();

    if (daySlots.isEmpty) {
      return const SizedBox();
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch đã đặt trong ngày',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...daySlots.map(
            (slot) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: slot.isMyBooking
                    ? ThemeProvider.primaryColor.withOpacity(0.2)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '${DateFormat.Hm().format(slot.startTime)} - ${DateFormat.Hm().format(slot.endTime)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    slot.isMyBooking
                        ? 'Của bạn'
                        : slot.bookedByName ?? 'Đã đặt',
                    style: TextStyle(
                      color: slot.isMyBooking
                          ? ThemeProvider.primaryColor
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createBooking() async {
    if (_selectedCourt == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn sân')));
      return;
    }

    final startDateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giờ kết thúc phải sau giờ bắt đầu')),
      );
      return;
    }

    final success = await context.read<BookingProvider>().createBooking(
      _selectedCourt!.id,
      startDateTime,
      endDateTime,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt sân thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadCalendar();
        context.read<WalletProvider>().loadBalance();
        context.read<AuthProvider>().refreshUser();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<BookingProvider>().errorMessage ??
                  'Đặt sân thất bại',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMyBookings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        context.read<BookingProvider>().loadMyBookings();

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Booking của tôi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Consumer<BookingProvider>(
                      builder: (context, booking, _) {
                        if (booking.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (booking.myBookings.isEmpty) {
                          return const EmptyState(
                            message: 'Bạn chưa có booking nào',
                            icon: Icons.calendar_today_outlined,
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: booking.myBookings.length,
                          itemBuilder: (context, index) {
                            final b = booking.myBookings[index];
                            return GlassCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        b.courtName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            b.status,
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          b.status.displayName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _getStatusColor(b.status),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${DateFormat('dd/MM/yyyy HH:mm').format(b.startTime)} - ${DateFormat.Hm().format(b.endTime)}',
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'vi_VN',
                                      symbol: '₫',
                                    ).format(b.totalPrice),
                                    style: TextStyle(
                                      color: ThemeProvider.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (b.status == BookingStatus.confirmed) ...[
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () => _cancelBooking(b.id),
                                      child: const Text(
                                        'Hủy booking',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.pendingPayment:
        return Colors.orange;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }

  Future<void> _cancelBooking(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text(
          'Bạn có chắc muốn hủy booking này? Tiền hoàn trả sẽ tùy thuộc vào thời gian hủy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hủy booking',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<BookingProvider>().cancelBooking(id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hủy booking'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadCalendar();
          context.read<WalletProvider>().loadBalance();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hủy booking thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
