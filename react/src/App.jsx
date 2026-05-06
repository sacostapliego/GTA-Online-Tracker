import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [activeTab, setActiveTab] = useState('Home')
  const [weeklyUpdate, setWeeklyUpdate] = useState(null)
  const [loading, setLoading] = useState(true)

  const DATA_URL = "https://raw.githubusercontent.com/sacostapliego/GTA-Online-Tracker/refs/heads/main/Scraper/data/weekly-update.json"

  useEffect(() => {
    fetch(DATA_URL)
      .then(res => res.json())
      .then(data => {
        setWeeklyUpdate(data)
        setLoading(false)
      })
      .catch(err => {
        console.error("Failed to fetch data", err)
        setLoading(false)
      })
  }, [])

  if (loading) {
    return <div>Loading...</div>
  }

  return (
    <div style={{ padding: '20px', maxWidth: '800px', margin: '0 auto', fontFamily: 'sans-serif' }}>
      <h1>GTA Online Tracker</h1>
      
      <div style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
        {['Home', 'Bonuses', 'Discounts'].map(tab => (
          <button 
            key={tab}
            onClick={() => setActiveTab(tab)}
            style={{
              padding: '10px 20px',
              backgroundColor: activeTab === tab ? '#333' : '#eee',
              color: activeTab === tab ? 'white' : 'black',
              border: 'none',
              borderRadius: '5px',
              cursor: 'pointer'
            }}
          >
            {tab}
          </button>
        ))}
      </div>

      <div>
        {activeTab === 'Home' && weeklyUpdate && (
          <div>
            <h2>Week of: {weeklyUpdate.weekOf}</h2>
            <h3>Podium Vehicle</h3>
            <p>{weeklyUpdate.podiumVehicle}</p>
            <h3>Prize Ride</h3>
            <p>{weeklyUpdate.prizeRideVehicle}</p>
            <p><strong>Challenge:</strong> {weeklyUpdate.prizeRideChallenge}</p>
            <h3>Time Trials</h3>
            <ul>
              <li><strong>Time Trial:</strong> {weeklyUpdate.timeTrial}</li>
              <li><strong>Premium Race:</strong> {weeklyUpdate.premiumRace}</li>
              <li><strong>HSW Time Trial:</strong> {weeklyUpdate.hswTimeTrial}</li>
            </ul>
          </div>
        )}

        {activeTab === 'Bonuses' && weeklyUpdate && (
          <div>
            <h2>Bonuses</h2>
            <ul>
              {weeklyUpdate.bonuses.map((bonus, idx) => (
                <li key={idx} style={{ marginBottom: '10px' }}>{bonus}</li>
              ))}
            </ul>
          </div>
        )}

        {activeTab === 'Discounts' && weeklyUpdate && (
          <div>
            <h2>Discounts</h2>
            <ul>
              {weeklyUpdate.discounts.map((discount, idx) => (
                <li key={idx} style={{ marginBottom: '10px' }}>{discount}</li>
              ))}
            </ul>
          </div>
        )}
      </div>
    </div>
  )
}

export default App
