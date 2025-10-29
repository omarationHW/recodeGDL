<template>
  <div class="stats-container">
    <div class="stat-card">
      <h3>Total Contratos</h3>
      <div class="value">{{ totalContratos }}</div>
    </div>
    <div class="stat-card">
      <h3>Total Adeudos</h3>
      <div class="value">${{ formatCurrency(totalAdeudos) }}</div>
    </div>
    <div class="stat-card">
      <h3>Inversión Total</h3>
      <div class="value">${{ formatCurrency(totalInversion) }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'StatsCards',
  props: {
    totalContratos: {
      type: Number,
      default: 0
    },
    totalAdeudos: {
      type: Number,
      default: 0
    },
    totalInversion: {
      type: Number,
      default: 0
    }
  },
  methods: {
    formatCurrency(amount) {
      return parseFloat(amount || 0).toLocaleString('es-MX', {
        minimumFractionDigits: 2
      });
    }
  }
}
</script>