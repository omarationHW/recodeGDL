<template>
  <div class="table-container">
    <div v-if="loading" class="loading">
      <div class="loading-spinner"></div>
      <p>Cargando datos...</p>
    </div>
    
    <div v-else-if="proyectos.length === 0" class="empty-state">
      <h3>No hay contratos registrados</h3>
      <p>Haz clic en "Alta Contrato" para comenzar</p>
    </div>
    
    <table v-else>
      <thead>
        <tr>
          <th>ID</th>
          <th>Contrato</th>
          <th>Nombre</th>
          <th>Calle</th>
          <th class="text-right">Metros</th>
          <th class="text-right">Costo/Mtr</th>
          <th class="text-right">Costo Total</th>
          <th>Pavimento</th>
          <th class="text-right">Adeudo</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="proyecto in proyectos" :key="proyecto.id_control">
          <td>{{ proyecto.id_control }}</td>
          <td>{{ proyecto.contrato }}</td>
          <td>{{ proyecto.nombre }}</td>
          <td>{{ proyecto.calle }}</td>
          <td class="text-right">{{ proyecto.metros }}</td>
          <td class="text-right">${{ formatCurrency(proyecto.costomtr) }}</td>
          <td class="text-right">${{ formatCurrency(proyecto.costototal) }}</td>
          <td>{{ proyecto.pavimento_descripcion }}</td>
          <td class="text-right">${{ formatCurrency(proyecto.adeudo_total) }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  name: 'ProyectosTable',
  props: {
    proyectos: {
      type: Array,
      default: () => []
    },
    loading: {
      type: Boolean,
      default: false
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