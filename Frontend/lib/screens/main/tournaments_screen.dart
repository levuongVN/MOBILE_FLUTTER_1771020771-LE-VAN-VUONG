import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<TournamentProvider>().loadTournaments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giải đấu'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mở đăng ký'),
            Tab(text: 'Đang diễn ra'),
            Tab(text: 'Đã kết thúc'),
          ],
          indicatorColor: ThemeProvider.primaryColor,
          labelColor: ThemeProvider.primaryColor,
        ),
      ),
      body: Consumer<TournamentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.tournaments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTournamentList(
                provider.tournaments
                    .where(
                      (t) =>
                          t.status == TournamentStatus.open ||
                          t.status == TournamentStatus.registering,
                    )
                    .toList(),
              ),
              _buildTournamentList(
                provider.tournaments
                    .where(
                      (t) =>
                          t.status == TournamentStatus.ongoing ||
                          t.status == TournamentStatus.drawCompleted,
                    )
                    .toList(),
              ),
              _buildTournamentList(
                provider.tournaments
                    .where((t) => t.status == TournamentStatus.finished)
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTournamentList(List<Tournament> tournaments) {
    if (tournaments.isEmpty) {
      return const EmptyState(
        message: 'Không có giải đấu nào',
        icon: Icons.emoji_events_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TournamentProvider>().loadTournaments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tournaments.length,
        itemBuilder: (context, index) {
          final tournament = tournaments[index];
          return _buildTournamentCard(tournament);
        },
      ),
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showTournamentDetail(tournament),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeProvider.accentColor,
                        ThemeProvider.accentColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            tournament.status,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tournament.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(tournament.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info rows
            _buildInfoRow(
              Icons.calendar_today,
              '${DateFormat('dd/MM').format(tournament.startDate)} - ${DateFormat('dd/MM/yyyy').format(tournament.endDate)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.sports_tennis,
              _getFormatName(tournament.format),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.people, tournament.participantDisplay),

            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phí tham gia',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      formatter.format(tournament.entryFee),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tổng giải thưởng',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      formatter.format(tournament.prizePool),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ThemeProvider.accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (tournament.canRegister && !tournament.isFull) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Đăng ký tham gia',
                  icon: Icons.add,
                  onPressed: () => _joinTournament(tournament),
                ),
              ),
            ],

            if (tournament.isFull && tournament.canRegister) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Đã đủ số lượng người tham gia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.open:
      case TournamentStatus.registering:
        return Colors.green;
      case TournamentStatus.drawCompleted:
        return Colors.blue;
      case TournamentStatus.ongoing:
        return ThemeProvider.accentColor;
      case TournamentStatus.finished:
        return Colors.grey;
    }
  }

  String _getFormatName(TournamentFormat format) {
    switch (format) {
      case TournamentFormat.knockout:
        return 'Loại trực tiếp';
      case TournamentFormat.roundRobin:
        return 'Vòng tròn';
      case TournamentFormat.hybrid:
        return 'Kết hợp';
    }
  }

  Future<void> _showTournamentDetail(Tournament tournament) async {
    await context.read<TournamentProvider>().loadTournamentDetail(
      tournament.id,
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TournamentDetailSheet(tournament: tournament),
    );
  }

  Future<void> _joinTournament(Tournament tournament) async {
    final teamNameController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng ký giải đấu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phí tham gia: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(tournament.entryFee)}',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: teamNameController,
              decoration: const InputDecoration(
                labelText: 'Tên đội (tùy chọn)',
                hintText: 'Nhập tên đội của bạn',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<TournamentProvider>().joinTournament(
        tournament.id,
        teamName: teamNameController.text.isNotEmpty
            ? teamNameController.text
            : null,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<WalletProvider>().loadBalance();
          context.read<AuthProvider>().refreshUser();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<TournamentProvider>().errorMessage ??
                    'Đăng ký thất bại',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _TournamentDetailSheet extends StatelessWidget {
  final Tournament tournament;

  const _TournamentDetailSheet({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Consumer<TournamentProvider>(
            builder: (context, provider, _) {
              final detail = provider.selectedTournament;

              if (provider.isLoading || detail == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            detail.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (detail.description != null) ...[
                            const SizedBox(height: 8),
                            Text(detail.description!),
                          ],
                          const SizedBox(height: 16),

                          // Participants section
                          const Text(
                            'Người tham gia',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  if (detail.participants.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final participant = detail.participants[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: ThemeProvider.primaryColor,
                            child: Text(
                              participant.displayName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(participant.displayName),
                          subtitle: participant.partnerName != null
                              ? Text('cùng ${participant.partnerName}')
                              : null,
                          trailing: participant.seed != null
                              ? Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ThemeProvider.accentColor
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '#${participant.seed}',
                                    style: TextStyle(
                                      color: ThemeProvider.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      }, childCount: detail.participants.length),
                    ),

                  if (detail.matches.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: const Text(
                          'Lịch thi đấu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final match = detail.matches[index];
                        return GlassCard(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Column(
                            children: [
                              if (match.roundName != null)
                                Text(
                                  match.roundName!,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      match.team1Display,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight:
                                            match.winningSide ==
                                                WinningSide.team1
                                            ? FontWeight.bold
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          match.status == MatchStatus.finished
                                          ? ThemeProvider.primaryColor
                                                .withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      match.status == MatchStatus.finished
                                          ? match.scoreDisplay
                                          : DateFormat.Hm().format(
                                              match.startTime,
                                            ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            match.status == MatchStatus.finished
                                            ? ThemeProvider.primaryColor
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      match.team2Display,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight:
                                            match.winningSide ==
                                                WinningSide.team2
                                            ? FontWeight.bold
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }, childCount: detail.matches.length),
                    ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
